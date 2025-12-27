# Video Loop Player

A simple video loop player for Raspberry Pi that plays videos from Google Drive on an HDMI display.

## Features

- Fullscreen video playback with no audio
- Syncs from Google Drive every 30 minutes
- Automatically switches to new videos when uploaded
- Auto-starts on boot (no desktop environment needed)
- Supports multiple video formats (mp4, mkv, avi, mov, webm, m4v, wmv, flv)

## Requirements

- Raspberry Pi (tested on Pi 4)
- Raspberry Pi OS Lite (64-bit)
- HDMI display
- Internet connection

## Installation

1. Clone this repo to your Pi:
   ```bash
   git clone https://github.com/ken10677/videoloop.git
   cd videoloop
   ```

2. Run the setup script:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. Configure rclone for Google Drive:
   ```bash
   rclone config
   ```
   - Create a new remote named `gdrive`
   - Choose Google Drive
   - Follow the OAuth flow

4. Create a folder called `VideoLoop` in your Google Drive

5. Upload a video to the VideoLoop folder

6. Reboot:
   ```bash
   sudo reboot
   ```

## Usage

- Upload videos to your Google Drive `VideoLoop` folder
- The Pi will sync every 30 minutes and switch to new videos
- Videos play in fullscreen with no audio, looping continuously

## Configuration

Edit `player.sh` to customize:
- `VIDEO_DIR` - Local video storage path
- `SYNC_INTERVAL` - How often to sync from Google Drive (in seconds)

## Files

- `player.sh` - Main video player script
- `xinitrc` - X session configuration
- `setup.sh` - Installation script

## Troubleshooting

**No video playing:**
- Check rclone config: `rclone lsd gdrive:`
- Verify VideoLoop folder exists in Google Drive
- Check for videos: `ls ~/videoloop/videos/`

**Screen goes blank:**
- X power management should be disabled, but you can verify with `xset q`

**VLC errors:**
- Check VLC is installed: `vlc --version`
- Try playing manually: `cvlc --no-audio --fullscreen /path/to/video.mp4`
