#!/bin/bash

# Check if the script is run as root
if [[ "$EUID" -ne 0 ]]; then
    echo "Please run as root."
    exit 1
fi

# Base path for the main directories
base_path="/mnt"
# Base path for the data directories
data_base_path="/mnt/data"
# Base path for the Life directory
life_base_path="/mnt/Life"

# Directories to create at /mnt
mnt_directories=(
    "cams"
    "data"
    "hello"
    "Life"
    "mashed"
    "photobu"
    "zoneminder"
)

# Directories to create at /mnt/data
data_directories=(
    "NAS_1"
    "NAS_2"
    "NAS_3"
    "NAS_4"
    "NAS_6"
    "NAS_7"
)

# Directories to create at /mnt/Life
life_directories=(
    "1-Parity"
    "2-Parity"
)

# Create directories at /mnt
for dir in "${mnt_directories[@]}"; do
    dir_path="$base_path/$dir"
    
    # Check if the directory already exists
    if [[ ! -d "$dir_path" ]]; then
        echo "Creating directory: $dir_path"
        mkdir -p "$dir_path"  # Create the directory if it doesn't exist
    else
        echo "Directory already exists: $dir_path"
    fi

    # Set permissions to 777
    chmod 777 "$dir_path"
    echo "Set permissions 777 for $dir_path"
done

# Create directories at /mnt/data
for dir in "${data_directories[@]}"; do
    dir_path="$data_base_path/$dir"
    
    # Check if the directory already exists
    if [[ ! -d "$dir_path" ]]; then
        echo "Creating directory: $dir_path"
        mkdir -p "$dir_path"  # Create the directory if it doesn't exist
    else
        echo "Directory already exists: $dir_path"
    fi

    # Set permissions to 777
    chmod 777 "$dir_path"
    echo "Set permissions 777 for $dir_path"
done

# Create directories at /mnt/Life
for dir in "${life_directories[@]}"; do
    dir_path="$life_base_path/$dir"
    
    # Check if the directory already exists
    if [[ ! -d "$dir_path" ]]; then
        echo "Creating directory: $dir_path"
        mkdir -p "$dir_path"  # Create the directory if it doesn't exist
    else
        echo "Directory already exists: $dir_path"
    fi

    # Set permissions to 777
    chmod 777 "$dir_path"
    echo "Set permissions 777 for $dir_path"
done

echo "All directories created and permissions set!"
