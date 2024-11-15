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
sudo systemctl enable --now nginx

# Enable and start Transmission daemon service
echo "Enabling and starting Transmission daemon service..."
sudo systemctl enable --now transmission-daemon

# Enable and start Samba service
echo "Enabling and starting Samba service..."
sudo systemctl enable --now smbd

# Enable and start Plex Media Server service
echo "Enabling and starting Plex Media Server service..."
sudo systemctl enable --now plexmediaserver

# Enable and start MotionEye service
echo "Enabling and starting MotionEye service..."
sudo systemctl enable --now motioneye

# Enable and start Homebridge service
echo "Enabling and starting Homebridge service..."
sudo systemctl enable --now homebridge

echo "All services have been enabled and started."

# Prompt to reboot the system
read -p "Would you like to reboot the system now? (Y/N): " REBOOT_CHOICE

case "$REBOOT_CHOICE" in
  [Yy]* ) 
    echo "Rebooting system..."
    sudo reboot
    ;;
  [Nn]* ) 
    echo "Reboot canceled. You can reboot manually if needed."
    ;;
  * ) 
    echo "Invalid input. Please enter Y or N."
    ;;
esac
