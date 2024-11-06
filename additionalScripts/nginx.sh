#!/bin/bash

# nginx.sh

# Check if the script is run as root or with sudo
if [[ "$EUID" -ne 0 ]]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

# Update package list
echo "Updating package list..."
sudo apt update

# Install Nginx
echo "Installing Nginx..."
sudo apt install -y nginx

# Install PHP and PHP-FPM
echo "Installing PHP and PHP-FPM..."
sudo apt install -y php php-fpm


echo "Nginx, PHP, and PHP-FPM installed."
