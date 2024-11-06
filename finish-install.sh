#!/bin/bash

# finish-install.sh

# Check if the script is run as root or with sudo
if [[ "$EUID" -ne 0 ]]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

# Enable and start Nginx service
echo "Enabling and starting Nginx service..."
sudo systemctl enable nginx
sudo systemctl start nginx

# Enable and start Transmission daemon service
echo "Enabling and starting Transmission daemon service..."
sudo systemctl enable transmission-daemon
sudo systemctl start transmission-daemon

# Enable and start Samba service
echo "Enabling and starting Samba service..."
sudo systemctl enable smbd
sudo systemctl start smbd

# Enable and start Plex Media Server service
echo "Enabling and starting Plex Media Server service..."
sudo systemctl enable plexmediaserver
sudo systemctl start plexmediaserver

# Enable and start SnapRAID service
echo "Enabling and starting SnapRAID service..."
# Uncomment and adjust the following lines if you have set up SnapRAID as a service
sudo systemctl enable snapraid
sudo systemctl start snapraid

# Enable and start MotionEye service
echo "Enabling and starting MotionEye service..."
sudo systemctl enable motioneye
sudo systemctl start motioneye

# Enable and start Homebridge service
echo "Enabling and starting Homebridge service..."
sudo systemctl enable homebridge
sudo systemctl start homebridge

echo "All services enabled and started."
echo "The system will now reboot."
sleep 10  # Pause for 10 seconds
sudo reboot
