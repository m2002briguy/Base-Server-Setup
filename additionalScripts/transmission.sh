#!/bin/bash

# transmission.sh

# Check if the script is run as root or with sudo
if [[ "$EUID" -ne 0 ]]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

# Update package list
echo "Updating package list..."
sudo apt update

# Install Transmission packages
echo "Installing Transmission CLI, Daemon, and Desktop application..."
sudo apt install -y transmission-cli transmission-daemon transmission-gtk


#start the transmission daemon
sudo systemctl enable transmission-daemon
sudo systemctl start transmission-daemon

echo "Transmission installed."
