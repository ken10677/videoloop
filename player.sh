#!/bin/bash
# Video Loop Player - Plays videos from Google Drive in a continuous loop
# Designed for Raspberry Pi with HDMI display

VIDEO_DIR="/home/ken/videoloop/videos"
SYNC_INTERVAL=1800  # 30 minutes in seconds

mkdir -p "$VIDEO_DIR"

find_video() {
    find "$VIDEO_DIR" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.webm" -o -iname "*.m4v" -o -iname "*.wmv" -o -iname "*.flv" \) 2>/dev/null | head -1
}

sync_videos() {
    echo "[$(date)] Syncing from Google Drive..."
    rclone sync gdrive:VideoLoop "$VIDEO_DIR" --verbose 2>&1
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

    echo "[$(date)] Playing: $VIDEO"

    # Start VLC in fullscreen, no audio, looping
    DISPLAY=:0 cvlc --no-audio --loop --fullscreen --no-video-title-show --no-osd "$VIDEO" &
    VLC_PID=$!
    LAST_SYNC=$(date +%s)

    # Monitor playback, check for new videos every minute, sync every 30 min
    while kill -0 $VLC_PID 2>/dev/null; do
        sleep 60

        # Check if current video still exists (rclone may have removed it)
        if [ ! -f "$VIDEO" ]; then
            echo "[$(date)] Current video was removed, switching..."
            kill $VLC_PID 2>/dev/null
            break
        fi

        # Check if a different video is now available
        NEW_VIDEO=$(find_video)
        if [ -n "$NEW_VIDEO" ] && [ "$NEW_VIDEO" != "$VIDEO" ]; then
            echo "[$(date)] New video detected: $NEW_VIDEO"
            kill $VLC_PID 2>/dev/null
            break
        fi

        # Sync from Drive every 30 minutes
        CURRENT_TIME=$(date +%s)
        ELAPSED=$((CURRENT_TIME - LAST_SYNC))
        if [ $ELAPSED -ge $SYNC_INTERVAL ]; then
            sync_videos
            LAST_SYNC=$(date +%s)
        fi
    done

    sleep 2
done
