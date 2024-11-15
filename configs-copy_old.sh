#!/bin/bash

# Check if the script is run as root or with sudo
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root or with sudo."
  exit 1
fi

# Get PHP version (assuming PHP is installed and in PATH)
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION . '.' . PHP_MINOR_VERSION;" 2>/dev/null)

# Construct the PHP-FPM service name
PHP_FPM_SERVICE="php${PHP_VERSION}-fpm"


# Stop Nginx service
echo "Stopping Nginx service..."
sudo systemctl stop nginx

# Stop PHP-FPM service using the dynamic version
echo "Stopping $PHP_FPM_SERVICE service..."
sudo systemctl stop "$PHP_FPM_SERVICE"




# Stop the MotionEye service after installation
echo "Stopping MotionEye service..."
sudo systemctl stop motioneye



# Copy motioneye files to /etc/motioneye/
cp ./configs/motioneye/* /etc/motioneye/


echo "starting MotionEye service..."
sudo systemctl start motioneye

# Copy nginx files to /etc/nginx/sites-enabled/
cp ./configs/nginx/* /etc/nginx/sites-enabled/

# Get PHP version (assuming PHP is installed and in PATH)
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION . '.' . PHP_MINOR_VERSION;" 2>/dev/null)

if [ -z "$PHP_VERSION" ]; then
  echo "Error: PHP is not installed or not in the PATH."
  exit 1
fi

# Copy php-fpm files to /etc/php/$PHP_VERSION/fpm/
cp ./configs/php-fpm/* /etc/php/$PHP_VERSION/fpm/


# Start Nginx service
echo "Startinging Nginx service..."
sudo systemctl start nginx

# Start PHP-FPM service using the dynamic version
echo "Starting $PHP_FPM_SERVICE service..."
sudo systemctl start "$PHP_FPM_SERVICE"


# Stop the smbd service
echo "Stopping smbd service..."
sudo systemctl stop smbd

# Copy samba files to /etc/samba/
cp ./configs/samba/* /etc/samba/

# Start the smbd service
echo "Stopping smbd service..."
sudo systemctl start smbd



# Copy snapraid files to /etc/
cp ./configs/snapraid/* /etc/



#stop the transmission daemon
sudo systemctl stop transmission-daemon

# Copy transmission files to /etc/transmission-daemon/
cp ./configs/transmission/* /etc/transmission-daemon/


#start the transmission daemon
sudo systemctl start transmission-daemon

echo "All configuration files have been copied successfully."
