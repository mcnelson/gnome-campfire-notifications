Gem::Specification.new do |s|
  s.name        = 'gnome-campfire-notifications'
  s.version     = '0.1.2'
  s.summary     = "GNOME desktop notifications for Campfire."
  s.description = "A Ruby script that spawns GNOME desktop notifications when something is said in your Campfire chatroom."
  s.authors     = ["Michael Nelson"]
  s.email       = 'michael@nelsonware.com'
  s.executables << "gnome-campfire-notifications"
  s.files       = ["lib/gnome-campfire-notifications.rb", "assets/campfire.png"]
  s.homepage    = 'https://github.com/mcnelson/gnome-campfire-notifications'

  s.add_dependency 'twitter-stream'
end
