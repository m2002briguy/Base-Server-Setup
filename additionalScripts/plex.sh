#!/bin/bash

# plex.sh

# Check if the script is run as root or with sudo
if [[ "$EUID" -ne 0 ]]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

# Update package list
echo "Updating package list..."
sudo apt update

# Install required dependencies
echo "Installing dependencies for Plex Media Server..."
sudo apt install -y apt-transport-https curl

# Add the Plex Media Server repository
echo "Adding Plex Media Server repository..."
curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add -
echo "deb https://downloads.plex.tv/repo/deb public main" | sudo tee /etc/apt/sources.list.d/plexmediaserver.list

# Update package list again after adding the repository
echo "Updating package list again..."
sudo apt update

# Install Plex Media Server
echo "Installing Plex Media Server..."
sudo apt install -y plexmediaserver

# Start the Plex Media Server service
echo "Starting Plex Media Server service..."
sudo systemctl enable plexmediaserver
sudo systemctl start plexmediaserver

echo "Plex Media Server installed and started."
