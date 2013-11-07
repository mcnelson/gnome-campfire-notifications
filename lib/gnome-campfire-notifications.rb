require "twitter/json_stream"
require "json"
require "yaml"
require "net/http"

class GnomeCampfireNotifications
  HOST = 'streaming.campfirenow.com'

  def self.start
    room_name = ENV['GNOME_CAMPFIRE_NOTIFICATIONS_ROOM_NAME']
    room_id = ENV['GNOME_CAMPFIRE_NOTIFICATIONS_ROOM_ID']
    token   = ENV['GNOME_CAMPFIRE_NOTIFICATIONS_TOKEN']

    unless room_name && room_id && token
      raise "please set GNOME_CAMPFIRE_NOTIFICATIONS_ROOM_ID and GNOME_CAMPFIRE_NOTIFICATIONS_TOKEN"
    end

    new(
      path:       "/room/#{room_id}/live.json",
      host:       HOST,
      auth:       "#{token}:x",
      token:      token,
      room_name:  room_name
    )
  end

  def initialize(options)
    @options = options
    @username_cache = []
    listen
  end

  private

  def listen
    on_message do |item|
      username = get_username(item["user_id"].to_i)
      message = "#{item["body"].to_s.gsub(/'/, "\'")}"

      system("notify-send --hint=int:transient:1 -u low '#{username}' '#{message}'")
    end
  end

  def on_message
    EventMachine::run do
      stream = Twitter::JSONStream.connect(@options)

      stream.each_item { |i| yield(JSON.parse(i)) if i["type"] == "TextMessage" }
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

  def room_url
    "#{@options[:room_name]}.campfirenow.com"
  end
end
