#!/bin/bash

# install_motioneye.sh

# Check if the script is run as root or with sudo
if [[ "$EUID" -ne 0 ]]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

# Update package list
echo "Updating package list..."
sudo apt update

# Install required packages
echo "Installing required packages..."


sudo apt --no-install-recommends install ca-certificates curl python3 python3-dev libcurl4-openssl-dev gcc libssl-dev
sudo curl -sSfO 'https://bootstrap.pypa.io/get-pip.py'
sudo python3 get-pip.py
sudo grep -q '\[global\]' /etc/pip.conf 2> /dev/null || printf '%b' '[global]\n' | sudo tee -a /etc/pip.conf > /dev/null
sudo sed -i '/^\[global\]/a\break-system-packages=true' /etc/pip.conf
sudo python3 -m pip install --pre motioneye
sudo pip3 install --upgrade tornado
sudo motioneye_init





sudo apt install -y \
    motion \
    python3 \
    python3-pip \
    python3-dev \
    libssl-dev \
    libjpeg-dev \
    libz-dev \
    libfreetype6-dev \
    ffmpeg \
    v4l-utils \
    git \
    build-essential \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libpq-dev \
    python3-pyqt5

    echo "MotionEye installation complete. You can access it via http://<your-ip>:8765 (service is currently stopped)."
