# GNOME Campfire Notifications
A Ruby script that issues GNOME desktop notifications when something is said in your Campfire chatroom.

# Installation
`gem install gnome-campfire-notifications`

In your `~/.campfire.yml`:

  token:     (API access token under My info in the chatroom web app)
  subdomain: ("sample" as in "sample.campfirenow.com/room/123456")
  roomid:    ("123456" as in "sample.campfirenow.com/room/123456")
  self_user: 'Michael Nelson' (So that you don't get notified of your own messages)
  filter:    !ruby/regexp '/Michael Nelson/' (Send only messages matching this regex. Omit to disable.)

# Usage
Execute `gnome-campfire-notifications`.

# Help
Please feel free to open an issue or PR. Or feel free to contact me via my info on my Github user page.
