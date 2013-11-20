Gem::Specification.new do |s|
  s.name        = "gnome-campfire-notifications"
  s.version     = "0.2.1"
  s.summary     = "GNOME desktop notifications for Campfire."
  s.description = "A Ruby script that issues GNOME desktop notifications when something is said in your Campfire chatroom."
  s.authors     = ["Michael Nelson"]
  s.email       = "michael@nelsonware.com"
  s.executables << "gnome-campfire-notifications"
  s.files       = `git ls-files`.split
  s.test_files  = `git ls-files -- test/*`.split
  s.homepage    = "https://github.com/mcnelson/gnome-campfire-notifications"
  s.license     = "LGPL-2.0"

  s.add_dependency              'twitter-stream'
  s.add_development_dependency  'minitest'
  s.add_development_dependency  'vcr'
  s.add_development_dependency  'webmock'
end
