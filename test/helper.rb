require "minitest/autorun"
require "gnome-campfire-notifications"
require "vcr"
require "webmock"

VCR.configure do |c|
  c.cassette_library_dir = 'test/cassettes'
  c.hook_into :webmock
end

GnomeCampfireNotifications.class_eval do
  def load_dummy_config(hash = {})
    @config = {
      token:     'abcdefg12345678',
      roomid:    1,
      subdomain: 'example'
    }.merge(hash)
  end
end
