require "twitter/json_stream"
require "net/http"
require "json"

class GnomeCampfireNotifications
  HOST = 'streaming.campfirenow.com'
  ATTR_MAP = {
    room_name:  'GNOME_CAMPFIRE_NOTIFICATIONS_ROOM_NAME',
    room_id:    'GNOME_CAMPFIRE_NOTIFICATIONS_ROOM_ID',
    token:      'GNOME_CAMPFIRE_NOTIFICATIONS_TOKEN'
  }

  def initialize
    if (missing = ATTR_MAP.values.select { |env| ENV[env].empty? }).any?
      raise "please set environment variable(s) #{missing.join(', ')}"
    end

    @options = ATTR_MAP.map.with_object({}) { |(key, env), opts| opts[key] = ENV[env] }
    @username_cache = []
    try_icon
  end

  def start
    on_message do |item|
      username = get_username(item["user_id"].to_i)
      message = "#{item["body"].to_s.gsub(/'/, "\'")}"

      system("notify-send --hint=int:transient:1 -u low#{icon} '#{username}' '#{message}'")
    end
  end

  private

  def on_message
    EventMachine::run do
      stream = Twitter::JSONStream.connect(
        host:  HOST,
        path: "/room/#{room_id}/live.json",
        auth: "#{token}:x",
      )

      stream.each_item do |item|
        json = JSON::parse(item)
        if json["type"] == "TextMessage"
          yield(json)
        end
      end

      stream.on_error { |m| puts "ERROR: #{m.inspect}" }
      stream.on_max_reconnects { |timeout, retries| puts "Tried #{retries} times to connect." }
    end
  end

  def get_username(id)
    return "Unknown" if id.nil?

    unless @username_cache[id]
      req = Net::HTTP::Get.new("https://#{room_url}/users/#{id}.json")
      req.basic_auth(@options[:token], "x")
      http = Net::HTTP.new(room_url, 443)
      http.use_ssl = true
      resp = http.start { |h| h.request(req) }

      json = JSON.parse(resp.body)

      # Get username
      @username_cache[id] = json["user"]["name"]
    end

    @username_cache[id]
  end

  def icon
    " -i #{@options[:icon_path]}"
  end

  def try_icon
    system_path = "/usr/share/icons/gnome/32x32/apps/campfire.png"
    gem_path = "#{gem_dir}/assets/campfire.png"

    if File.exists?(gem_path)
      @options[:icon_path] = gem_path
    elsif File.exists?(system_path)
      @options[:icon_path] = system_path
    end
  end

  def gem_dir
    Gem::Specification.find_by_name("gnome-campfire-notifications").gem_dir
  end

  def room_url
    "#{@options[:room_name]}.campfirenow.com"
  end

  def room_id
    @options[:room_id]
  end

  def token
    @options[:token]
  end
end
