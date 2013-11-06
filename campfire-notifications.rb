require "twitter/json_stream"
require "json"
require "yaml"

token = ENV['GNOME_CAMPFIRE_NOTIFICATIONS_TOKEN']
room_id = ENV['GNOME_CAMPFIRE_NOTIFICATIONS_ROOM_ID']

$options = {
  :path => "/room/#{room_id}/live.json",
  :host => 'streaming.campfirenow.com',
  :auth => "#{token}:x"
}

$username_cache = []
$username_cache[123456] = "Username"

def get_username(id)
  return "Unknown" if id.nil?
  unless $username_cache[id]
    # Get username
    $username_cache[id] = "Unknown"
  end

  $username_cache[id]
end

EventMachine::run do
  stream = Twitter::JSONStream.connect($options)

  stream.each_item do |item_json|
    item = JSON.parse(item_json)

    if item["type"] == "TextMessage"
      username = get_username(item["user_id"].to_i)
      message = "'#{ item["body"].to_s.gsub(/'/, '\"') }'"
      command = "notify-send --hint=int:transient:1 -u low -i /usr/share/icons/gnome/32x32/apps/campfire.png '#{username}' #{message}"

      puts "WHO IS: #{item["user_id"]} - #{item["body"]}" if username == "Unknown"

      system command
    end
  end

  stream.on_error do |message|
    puts "ERROR: #{message.inspect}"
  end

  stream.on_max_reconnects do |timeout, retries|
    puts "Tried #{retries} times to connect."
    exit
  end
end
