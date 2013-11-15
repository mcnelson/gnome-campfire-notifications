require "twitter/json_stream"
require "net/http"
require "json"
require "yaml"

class GnomeCampfireNotifications
  HOST = 'streaming.campfirenow.com'
  NOTIFICATION_GFX_FILENAME = 'campfire.png'
  NOTIFICATION_GFX_SYSPATH = "/usr/share/icons/gnome/32x32/apps"

  CONFIG_SYSPATH = "#{ENV['HOME']}/.campfire.yml"
  CONFIG_ATTRS = %i(token subdomain roomid self_user filter icon_path)
  REQD_CONFIG_ATTRS = %i(token subdomain roomid)

  attr_reader :config

  def initialize
    @username_cache = []

    load_config
    try_icon unless @config[:icon_path]
  end

  def start
    on_message do |item|
      send_notification(item)
    end
  end

  def send_notification(item)
    username = get_username(item["user_id"].to_i)

    if should_send?(username, item["body"])
      system("notify-send --hint=int:transient:1 -u low#{icon} \"#{username}\" \"#{escape_for_bash(item["body"])}\"")
    end
  end

  def get_username(id)
    return "Unknown" if id.nil?

    unless @username_cache[id]
      req = Net::HTTP::Get.new("https://#{room_url}/users/#{id}.json")
      req.basic_auth(@config[:token], "x")
      http = Net::HTTP.new(room_url, 443)
      http.use_ssl = true
      resp = http.start { |h| h.request(req) }

      json = JSON.parse(resp.body)

      # Get username
      @username_cache[id] = json["user"]["name"]
    end

    @username_cache[id]
  end

  def load_config
    raise "please create #{CONFIG_SYSPATH}, see Github page for details" unless File.exists?(CONFIG_SYSPATH)
    @config = YAML.load_file(CONFIG_SYSPATH).each.with_object({}) { |(k, v), h| h[k.to_sym] = v }

    if !(missing = REQD_CONFIG_ATTRS.delete_if { |k| @config[k] }).empty?
      raise "please set config option(s) in #{CONFIG_SYSPATH}: #{missing.join(', ')}"
    end
  end

  private

  def on_message
    EventMachine::run do
      stream = Twitter::JSONStream.connect(
        host:  HOST,
        path: "/room/#{@config[:roomid]}/live.json",
        auth: "#{@config[:token]}:x",
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

  def should_send?(username, body)
    return false if @config[:self_user] && username == @config[:self_user]
    return !body.match(@config[:filter]).nil? if @config[:filter]

    true
  end

  def icon
    " -i #{@config[:icon_path]}"
  end

  def try_icon
    if path = notification_gfx_paths.detect { |p| File.exists?(p) }
      @config[:icon_path] = path
    end
  end

  def notification_gfx_paths
    [[NOTIFICATION_GFX_SYSPATH, NOTIFICATION_GFX_FILENAME],
     [gem_dir, "assets", NOTIFICATION_GFX_FILENAME]].map { |p| p.join('/') }
  end

  def gem_dir
    Gem::Specification.find_by_name("gnome-campfire-notifications").gem_dir
  end

  def room_url
    "#{@config[:subdomain]}.campfirenow.com"
  end

  def escape_for_bash(string)
    string.gsub(/("|`)/, '\\\\\\1')
  end
end
