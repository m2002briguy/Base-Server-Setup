#!/bin/bash

# snapraid.sh

# Check if the script is run as root or with sudo
if [[ "$EUID" -ne 0 ]]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

# Update package list
echo "Updating package list..."
sudo apt update

# Install SnapRAID and mergerfs
echo "Installing SnapRAID and mergerfs..."
sudo apt install -y snapraid mergerfs


echo "SnapRAID and mergerfs installed."
