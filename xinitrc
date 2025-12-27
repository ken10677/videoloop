#!/bin/bash
# X session configuration for video loop display
# Copy to ~/.xinitrc on the Pi

# Disable screen blanking and power management
xset s off
xset -dpms
xset s noblank

# Hide cursor
unclutter -idle 0.1 -root &

# Start the video player
exec /home/ken/videoloop/player.sh
