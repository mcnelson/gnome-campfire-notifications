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
    on_stream_item do |item|
      if item["type"] == "TextMessage"
        get_username(item["user_id"].to_i) do |username|
          message = "'#{ item["body"].to_s.gsub(/'/, '\"') }'"
          system("notify-send --hint=int:transient:1 -u low '#{username}' #{message}")
        end
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
    if @username_cache[id]
      yield(@username_cache[id])
    else
      http = Net::HTTP::Get.new("https://#{room_url}/users/#{id}.json")
      http.basic_auth(@options[:token], "x")
      Net::HTTP.start(room_url, 443) do |response|
        json = JSON.parse(response.body)
        @username_cache[id] = json["user"]["name"]

        yield(@username_cache[id])
      end
    end
  end

  def room_url
    "#{@options[:room_name]}.campfirenow.com"
  end
end
