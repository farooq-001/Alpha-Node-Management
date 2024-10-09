#!/bin/bash
# Variables
USERNAME="snb-tech"
PASSWORD="Sanem25-AUG1999"
NODE_ZIP="NodeManagement.zip"
NODE_DIR="/opt/NodeManagement"
SERVICE_FILE="alpha-nodes.service"

# Check if script is run with sudo/root privileges
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script as root or use sudo."
  exit 1
fi

# Create user if it does not exist
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists."
else
    sudo useradd -m "$USERNAME"
    echo "$USERNAME:$PASSWORD" | sudo chpasswd
    echo "User $USERNAME has been created and password has been set."
fi

# Determine the package manager
if command -v apt-get &> /dev/null
then
    PKG_MANAGER="apt"
elif command -v yum &> /dev/null
then
    PKG_MANAGER="yum"
else
    echo "Neither apt-get nor yum found. Exiting."
    exit 1
fi

# Update the package lists and install required packages
if [ "$PKG_MANAGER" = "apt" ]; then
    sudo apt update
    sudo apt install -y unzip python3 python3-pip
elif [ "$PKG_MANAGER" = "yum" ]; then
    sudo yum update -y
    sudo yum install -y unzip python3 python3-pip
fi

# Unzip the NodeManagement.zip file to /opt/
if [ -f "$NODE_ZIP" ]; then
    sudo unzip "$NODE_ZIP" -d /opt/
else
    echo "Error: $NODE_ZIP file not found in the current directory."
    exit 1
fi

# Check if the directory was unzipped successfully
if [ -d "$NODE_DIR" ]; then
    echo "$NODE_ZIP successfully extracted to $NODE_DIR."
else
    echo "Error: Failed to extract $NODE_ZIP."
    exit 1
fi

sleep 1

# Navigate to the NodeManagement directory
cd "$NODE_DIR" || { echo "Failed to navigate to $NODE_DIR. Exiting."; exit 1; }

# Create a virtual environment and install required Python packages
python3 -m venv myenv
source myenv/bin/activate
pip3 install flask paramiko gunicorn

# Copy the service file to systemd directory and reload the daemon
if [ -f "$SERVICE_FILE" ]; then
    sudo cp -r "$SERVICE_FILE" /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl start alpha-nodes
    sudo systemctl enable alpha-nodes
    echo "Service $SERVICE_FILE has been installed and started successfully."
else
    echo "Error: $SERVICE_FILE not found in the current directory."
    exit 1
fi

echo "Installation and setup complete."
