# GNOME Campfire Notifications
A Ruby script that spawns GNOME desktop notifications when something is said in your Campfire chatroom.

# Installation
Set environment variables:
- `GNOME_CAMPFIRE_NOTIFICATIONS_TOKEN` - Campfire API access token (under My info in the chatroom web app).
- `GNOME_CAMPFIRE_NOTIFICATIONS_ROOM_ID` - Room ID. It's the last segment in the Campfire URL: `https://whatever.campfirenow.com/room/123456`
- `GNOME_CAMPFIRE_NOTIFICATIONS_ROOM_NAME` - Room name. "sample" as in "sample.theclymb.com"

`gem install gnome-campfire-notifications`

# Usage
Simply execute `gnome-campfire-notifications`
