#!/bin/bash

# install_homebridge.sh

# Check if the script is run as root or with sudo
if [[ "$EUID" -ne 0 ]]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

# Add Homebridge GPG key
echo "Adding Homebridge GPG key..."
curl -sSfL https://repo.homebridge.io/KEY.gpg | sudo gpg --dearmor | sudo tee /usr/share/keyrings/homebridge.gpg > /dev/null

# Add Homebridge PPA
echo "Adding Homebridge PPA..."
echo "deb [signed-by=/usr/share/keyrings/homebridge.gpg] https://repo.homebridge.io stable main" | sudo tee /etc/apt/sources.list.d/homebridge.list > /dev/null

# Update package list
echo "Updating package list..."
sudo apt-get update

# Install Homebridge
echo "Installing Homebridge..."
sudo apt-get install -y homebridge

# Enable and start Homebridge service
echo "Enabling and starting Homebridge service..."
sudo systemctl enable homebridge
sudo systemctl start homebridge

# Stop the Homebridge service after installation
# echo "Stopping Homebridge service..."
# sudo systemctl stop homebridge

echo "Homebridge installation complete." 
# echo "The Homebridge service is currently stopped."
