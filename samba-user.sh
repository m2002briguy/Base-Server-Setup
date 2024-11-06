#!/bin/bash

# Check if the script is being run as root or with sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root or with sudo."
    exit 1
fi

# Define the username and password
USER="company"
PASSWORD="74123"

# Check if the user already exists on the system
if ! id "$USER" &>/dev/null; then
    echo "Creating system user $USER..."
    useradd -m "$USER"
else
    echo "User $USER already exists."
fi

# Set the system user's password
echo "$USER:$PASSWORD" | chpasswd

# Add the user to Samba (if not already added)
if ! pdbedit -L | grep -q "^$USER"; then
    echo "Adding Samba user $USER..."
    smbpasswd -a "$USER"
else
    echo "Samba user $USER already exists."
fi

# Set the Samba password for the user
echo -e "$PASSWORD\n$PASSWORD" | smbpasswd -s -a "$USER"

# Enable the Samba user (if needed)
smbpasswd -e "$USER"

# Display the user and Samba account info
echo "Samba user $USER created and enabled with the password $PASSWORD."
