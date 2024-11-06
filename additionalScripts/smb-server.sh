#!/bin/bash

# smb.sh

# Check if the script is run as root or with sudo
if [[ "$EUID" -ne 0 ]]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

# Update package list
echo "Updating package list..."
sudo apt update

# Install Samba server
echo "Installing Samba server..."
sudo apt install -y samba

# Stop the smbd service
echo "Stopping smbd service..."
#sudo systemctl stop smbd

echo "Samba server installed"

# Run the additional script
echo "Running additional script: samba-user.sh..."
bash ./samba-user.sh

echo "Samba user --company-- added."
