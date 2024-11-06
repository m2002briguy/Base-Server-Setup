#!/bin/bash

# install_motioneye.sh

# Check if the script is run as root or with sudo
if [[ "$EUID" -ne 0 ]]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

# Update package list
echo "Updating package list..."
sudo apt update

# Install required packages
echo "Installing required packages..."
sudo apt install -y \
    motion \
    python3 \
    python3-pip \
    python3-dev \
    libssl-dev \
    libjpeg-dev \
    libz-dev \
    libfreetype6-dev \
    ffmpeg \
    v4l-utils \
    git \
    build-essential \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libpq-dev \
    python3-pyqt5

# Install MotionEye using pip3
echo "Installing MotionEye..."
sudo pip3 install motioneye

# Create the MotionEye configuration directory
echo "Creating MotionEye configuration directory..."
sudo mkdir -p /etc/motioneye

# Initialize the MotionEye configuration
echo "Initializing MotionEye configuration..."
sudo motioneye_init

# Create systemd service file for MotionEye
echo "Creating systemd service file for MotionEye..."
cat <<EOF | sudo tee /etc/systemd/system/motioneye.service
[Unit]
Description=MotionEye Server
After=network.target motion.service

[Service]
ExecStart=/usr/local/bin/motioneye
WorkingDirectory=/usr/local/lib/python3.*/dist-packages/motioneye/
User=motioneye
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start Motion and MotionEye services
echo "Enabling and starting Motion service..."
sudo systemctl enable motion
sudo systemctl start motion

echo "Enabling and starting MotionEye service..."
sudo systemctl enable motioneye
sudo systemctl start motioneye

# Stop the MotionEye service after installation
echo "Stopping MotionEye service..."
# sudo systemctl stop motioneye

echo "MotionEye installation complete. You can access it via http://<your-ip>:8765 (service is currently stopped)."
