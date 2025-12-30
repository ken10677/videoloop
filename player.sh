#!/bin/bash
# Video Loop Player - Plays videos from Google Drive in a continuous loop
# Designed for Raspberry Pi with HDMI display

VIDEO_DIR="/home/ken/videoloop/videos"
SYNC_INTERVAL=1800  # 30 minutes in seconds
LAST_VIDEO=""

mkdir -p "$VIDEO_DIR"

find_video() {
    find "$VIDEO_DIR" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.webm" -o -iname "*.m4v" -o -iname "*.wmv" -o -iname "*.flv" \) 2>/dev/null | head -1
}

sync_videos() {
    echo "[$(date)] Syncing from Google Drive..."
    # --delete-before removes local files not in Drive before downloading
    rclone sync gdrive:VideoLoop "$VIDEO_DIR" --delete-before --verbose 2>&1
    echo "[$(date)] Sync complete"
}

# Initial sync
sync_videos

while true; do
    VIDEO=$(find_video)

    if [ -z "$VIDEO" ]; then
        echo "[$(date)] No video found, waiting..."
        sleep 30
        sync_videos
        continue
    fi

    LAST_VIDEO="$VIDEO"
    echo "[$(date)] Playing: $VIDEO"

    # Start VLC in fullscreen, no audio, looping
    DISPLAY=:0 cvlc --no-audio --loop --fullscreen --no-video-title-show --no-osd "$VIDEO" &
    VLC_PID=$!
    START_TIME=$(date +%s)

    # Monitor playback and sync periodically
    while kill -0 $VLC_PID 2>/dev/null; do
        sleep 60
        CURRENT_TIME=$(date +%s)
        ELAPSED=$((CURRENT_TIME - START_TIME))

        if [ $ELAPSED -ge $SYNC_INTERVAL ]; then
            sync_videos
            NEW_VIDEO=$(find_video)

            # If a new video is available, stop current and switch
            if [ -n "$NEW_VIDEO" ] && [ "$NEW_VIDEO" != "$LAST_VIDEO" ]; then
                echo "[$(date)] New video detected: $NEW_VIDEO"
                kill $VLC_PID 2>/dev/null
                sleep 2
            fi
            START_TIME=$(date +%s)
        fi
    done

    sleep 2
done
