#!/bin/bash
# Setup script for Video Loop Player on Raspberry Pi
# Run this script on the Pi to configure everything

set -e

echo "=== Video Loop Setup ==="

# Install dependencies
echo "Installing dependencies..."
sudo apt update
sudo apt install -y vlc rclone xserver-xorg xinit unclutter

# Create directories
echo "Creating directories..."
mkdir -p ~/videoloop/videos

# Copy player script
echo "Setting up player script..."
cp player.sh ~/videoloop/
chmod +x ~/videoloop/player.sh

# Setup xinitrc
echo "Configuring X session..."
cp xinitrc ~/.xinitrc
chmod +x ~/.xinitrc

# Configure auto-login
echo "Setting up auto-login on tty1..."
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf > /dev/null << 'EOF'
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin ken --noclear %I $TERM
EOF

# Configure bash_profile to start X on tty1
echo "Configuring auto-start..."
if ! grep -q "startx" ~/.bash_profile 2>/dev/null; then
    cat >> ~/.bash_profile << 'EOF'

# Auto-start X on tty1
if [ "$(tty)" = "/dev/tty1" ]; then
    exec startx ~/.xinitrc -- -nocursor
fi
EOF
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "1. Configure rclone for Google Drive:"
echo "   rclone config"
echo "   (Create a remote named 'gdrive' for Google Drive)"
echo ""
echo "2. Create a folder in Google Drive called 'VideoLoop'"
echo ""
echo "3. Upload a video to the VideoLoop folder"
echo ""
echo "4. Reboot: sudo reboot"
echo ""
