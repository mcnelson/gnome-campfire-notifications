Gem::Specification.new do |s|
  s.name        = 'GNOME Campfire Notifications'
  s.version     = '0.1.0'
  s.summary     = "GNOME desktop notifications for Campfire."
  s.description = "A Ruby script that spawns GNOME desktop notifications when something is said in your Campfire chatroom."
  s.authors     = ["mcnelson"]
  s.email       = 'michael@nelsonware.com'
  s.files       = ["lib/gnome-campfire-notifications.rb"]
  s.homepage    = 'https://rubygems.org/gems/example'

  s.add_dependency 'twitter-stream'
end
