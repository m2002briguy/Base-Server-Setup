#!/bin/bash

# master-install.sh

# Check if the script is run as root
if [[ "$EUID" -ne 0 ]]; then
    SUDO='sudo'
else
    SUDO=''
fi

# Update package list
echo "Updating package list..."
$SUDO apt update

# Install core packages
echo "Installing neofetch, ssh, python3, pip3, and Python dev tools..."
$SUDO apt install -y neofetch ssh python3 python3-pip python3-venv python3-dev build-essential

# Directory containing additional scripts
SCRIPT_DIR="additionalScripts"

# Check if the directory exists
if [[ ! -d "$SCRIPT_DIR" ]]; then
    echo "Directory $SCRIPT_DIR does not exist. Please create it and add your scripts."
    exit 1
fi

# Gather list of scripts
OPTIONS=()
for script in "$SCRIPT_DIR"/*.sh; do
    script_name=$(basename "$script")
    OPTIONS+=("$script_name" "" OFF)
done

# Display checklist and capture user selection
CHOICES=$(whiptail --title "Select Scripts to Install" \
    --checklist "Choose additional scripts to run:" 20 78 10 \
    "${OPTIONS[@]}" 3>&1 1>&2 2>&3)

# Check if the user pressed Cancel
if [[ $? -ne 0 ]]; then
    echo "No scripts selected. Exiting..."
    exit 0
fi

# Run selected scripts
echo "Running selected scripts..."
for script_name in $CHOICES; do
    # Remove quotes around the script name
    script_name=${script_name//\"/}
    script_path="$SCRIPT_DIR/$script_name"

    # Run the script with sudo if needed
    echo "Running $script_name..."
    $SUDO bash "$script_path"
done

# Prompt the user to finish the installation
echo
read -p "Would you like to finish the installation by running finish-install.sh? (YES/NO): " response

# Convert response to uppercase
response=$(echo "$response" | tr 'a-z' 'A-Z')

# If user says NO, prompt "Are you sure?"
if [[ "$response" == "NO" ]]; then
    while true; do
        read -p "Are you sure you want to skip finish-install.sh? (YES/NO): " confirm
        confirm=$(echo "$confirm" | tr 'a-z' 'A-Z')

        if [[ "$confirm" == "YES" ]]; then
            echo "Run finish-install.sh when you are ready to complete the installation."
            exit 0
        elif [[ "$confirm" == "NO" ]]; then
            if [[ -f "./finish-install.sh" ]]; then
                echo "Running finish-install.sh..."
                $SUDO bash ./finish-install.sh
                break
            else
                echo "finish-install.sh not found! Please make sure it's in the correct directory."
                exit 1
            fi
        else
            echo "Invalid response. Please enter 'YES' or 'NO'."
        fi
    done
fi

# If the user chooses YES initially, run finish-install.sh
if [[ "$response" == "YES" ]]; then
    if [[ -f "./finish-install.sh" ]]; then
        echo "Running finish-install.sh..."
        $SUDO bash ./finish-install.sh
    else
        echo "finish-install.sh not found! Please make sure it's in the correct directory."
        exit 1
    fi
fi

# Final completion message
echo "Installation Complete!"
