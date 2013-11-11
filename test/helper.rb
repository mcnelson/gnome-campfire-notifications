require "minitest/autorun"
require "gnome-campfire-notifications"
require "vcr"
require "webmock"

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock
end

ENV['GNOME_CAMPFIRE_NOTIFICATIONS_TOKEN'] = 'abcdefg12345678'
ENV['GNOME_CAMPFIRE_NOTIFICATIONS_ROOM_ID'] = '1'
ENV['GNOME_CAMPFIRE_NOTIFICATIONS_ROOM_NAME'] = "example"
