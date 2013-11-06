# GNOME Campfire Notifications
A Ruby script that spawns GNOME desktop notifications when something is said in your Campfire chatroom.

# Installation
1. `gem install twitter-stream`
2. Set `GNOME_CAMPFIRE_NOTIFICATIONS_TOKEN` to your Campfire API access token (under My info in the chatroom web app).
3. Set `GNOME_CAMPFIRE_NOTIFICATIONS_ROOM_ID` as your Room ID. It's the last segment in the Campfire URL: `https://whatever.campfirenow.com/room/123456`
4. `ruby campfire-notifications.rb`


Since this is a hackjob so far, you have to manually populate `$username_cache` by watching the output and matching up what is said in the chatoom to the correct user ID. See the script for an example.
