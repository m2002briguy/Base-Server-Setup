#!/bin/bash

# finish-install.sh

# Check if the script is run as root or with sudo
if [[ "$EUID" -ne 0 ]]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi


# Run the additional script to copy configurations
echo "Running additional script: configs-copy.sh..."
bash ./configs-copy.sh


# Enable and start Nginx service
echo "Enabling and starting Nginx service..."
sudo systemctl enable nginx

# Enable and start Transmission daemon service
echo "Enabling and starting Transmission daemon service..."
sudo systemctl enable transmission-daemon

# Enable and start Samba service
echo "Enabling and starting Samba service..."
sudo systemctl enable smbd

# Enable and start Plex Media Server service
echo "Enabling and starting Plex Media Server service..."
sudo systemctl enable plexmediaserver


# Enable and start MotionEye service
echo "Enabling and starting MotionEye service..."
sudo systemctl enable motioneye

# Enable and start Homebridge service
echo "Enabling and starting Homebridge service..."
sudo systemctl enable homebridge

echo "All services enabled."
echo "The system will now reboot."
sleep 10  # Pause for 10 seconds
sudo reboot
