# GNOME Campfire Notifications
A Ruby script that issues GNOME desktop notifications when something is said in your Campfire chatroom.

# Installation
`gem install gnome-campfire-notifications`

Set environment variables:
- `GNOME_CAMPFIRE_NOTIFICATIONS_TOKEN` - Campfire API access token (under My info in the chatroom web app).
- `GNOME_CAMPFIRE_NOTIFICATIONS_ROOM_ID` - Room ID. It's the last segment in the Campfire URL: `https://whatever.campfirenow.com/room/123456`
- `GNOME_CAMPFIRE_NOTIFICATIONS_ROOM_NAME` - Room name. "sample" as in "sample.campfirenow.com"

# Usage
Simply execute `gnome-campfire-notifications`.

Tell the script who you are so that you aren't notified of your own messages:
`export GNOME_CAMPFIRE_NOTIFICATIONS_SELF_USER=Michael Nelson`

If you only want to see messages that are directed at you, such as when someone says "Your Name: blah blah blah", flip this on:
`export GNOME_CAMPFIRE_NOTIFICATIONS_SELF_ONLY=true`

# Help
Please feel free to open an issue or PR. Or feel free to contact me via my info on my Github user page.
