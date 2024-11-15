#!/bin/bash

# Check if the script is run as root or with sudo
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root or with sudo."
  exit 1
fi

# Check if whiptail is installed
if ! command -v whiptail &> /dev/null; then
  echo "Error: whiptail is not installed. Install it with 'sudo apt install whiptail' and try again."
  exit 1
fi

# Get PHP version (assuming PHP is installed and in PATH)
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION . '.' . PHP_MINOR_VERSION;" 2>/dev/null)
PHP_FPM_SERVICE="php${PHP_VERSION}-fpm"

# Define services and corresponding copy actions
declare -A services=(
  ["MotionEye"]="/etc/motioneye"
  ["Nginx"]="/etc/nginx/sites-enabled"
  ["PHP-FPM"]="/etc/php/$PHP_VERSION/fpm"
  ["Samba"]="/etc/samba"
  ["Snapraid"]="/etc"
  ["Transmission"]="/etc/transmission-daemon"
)

# Define services' systemctl names for stop/start/enable operations
declare -A service_names=(
  ["MotionEye"]="motioneye"
  ["Nginx"]="nginx"
  ["PHP-FPM"]="$PHP_FPM_SERVICE"
  ["Samba"]="smbd"
  ["Transmission"]="transmission-daemon"
)

# Show menu with checkboxes for selection
selection=$(whiptail --title "Select Configs to Copy" --checklist "Choose configurations to copy:" 20 78 10 \
  "MotionEye" "Copy MotionEye config" OFF \
  "Nginx" "Copy Nginx config" OFF \
  "PHP-FPM" "Copy PHP-FPM config" OFF \
  "Samba" "Copy Samba config" OFF \
  "Snapraid" "Copy Snapraid config" OFF \
  "Transmission" "Copy Transmission config" OFF 3>&1 1>&2 2>&3)

# Exit if the user cancels
if [ $? -ne 0 ]; then
  echo "Operation cancelled."
  exit 0
fi

# Function to stop, copy config, start, and enable service
copy_config() {
  local service_name=$1
  local config_path=$2
  local source_path="./configs/${service_name,,}"

  echo "Stopping ${service_names[$service_name]} service..."
  sudo systemctl stop "${service_names[$service_name]}"

  echo "Copying $service_name files to $config_path..."
  cp -r "$source_path/"* "$config_path/"

  echo "Starting ${service_names[$service_name]} service..."
  sudo systemctl start "${service_names[$service_name]}"
  
  echo "Enabling ${service_names[$service_name]} service to start on boot..."
  sudo systemctl enable "${service_names[$service_name]}"
}

# Loop through selections and apply actions
for service in $selection; do
  service=$(echo $service | tr -d '"') # Remove quotes around selection
  if [ -n "${services[$service]}" ]; then
    copy_config "$service" "${services[$service]}"
  else
    echo "Error: Unknown service selected - $service"
  fi
done

echo "Selected configuration files have been copied and services enabled successfully."
