require "twitter/json_stream"
require "json"
require "yaml"

class GnomeCampfireNotifications
  HOST = 'streaming.campfirenow.com'

  def self.start
    room_id = ENV['GNOME_CAMPFIRE_NOTIFICATIONS_ROOM_ID']
    token   = ENV['GNOME_CAMPFIRE_NOTIFICATIONS_TOKEN']
    raise "please set GNOME_CAMPFIRE_NOTIFICATIONS_ROOM_ID and GNOME_CAMPFIRE_NOTIFICATIONS_TOKEN"

    new(
      path: "/room/#{room_id}/live.json",
      host: HOST,
      auth: "#{token}:x"
    )
  end

  def initialize(options)
    @options = {
      :path => "/room/#{ENV['GNOME_CAMPFIRE_NOTIFICATIONS_ROOM_ID']}/live.json",
      :host => 'streaming.campfirenow.com',
      :auth => "#{ENV['GNOME_CAMPFIRE_NOTIFICATIONS_TOKEN']}:x"
    }

    @username_cache = []
    @username_cache[123456] = "Username"

    listen
  end

  private

  def listen
    on_stream_item do |item|
      if item["type"] == "TextMessage"
        username = get_username(item["user_id"].to_i)
        message = "'#{ item["body"].to_s.gsub(/'/, '\"') }'"

        puts "WHO IS: #{item["user_id"]} - #{item["body"]}" if username == "Unknown"

        system("notify-send --hint=int:transient:1 -u low '#{username}' #{message}")
      end
    end
  end

  def on_stream_item
    EventMachine::run do
      stream = Twitter::JSONStream.connect(@options)

      stream.each_item { |i| yield(JSON.parse(i)) }
      stream.on_error { |m| puts "ERROR: #{m.inspect}" }
      stream.on_max_reconnects { |timeout, retries| puts "Tried #{retries} times to connect." }
    end
  end

  def get_username(id)
    return "Unknown" if id.nil?
    unless @username_cache[id]
      # Get username
      @username_cache[id] = "Unknown"
    end

    @username_cache[id]
  end
end
