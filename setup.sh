#!/bin/bash
# Variables
USERNAME="snb-tech"
PASSWORD="Sanem26-AUG1999"
NODE_ZIP="NodeManagement.zip"
NODE_DIR="/opt/NodeManagement"
SERVICE_FILE="alpha-nodes.service"
SERVICE_FILE_PATH="$(pwd)/$SERVICE_FILE" # Get absolute path of the service file

# Check if script is run with sudo/root privileges
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script as root or use sudo."
  exit 1
fi

# Create user if it does not exist
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists."
else
    useradd -m "$USERNAME"
    echo "$USERNAME:$PASSWORD" | chpasswd
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
    apt update
    apt install -y unzip python3 python3-pip
elif [ "$PKG_MANAGER" = "yum" ]; then
    yum update -y
    yum install -y unzip python3 python3-pip
fi

# Unzip the NodeManagement.zip file to /opt/
if [ -f "$NODE_ZIP" ]; then
    unzip "$NODE_ZIP" -d /opt/
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
pip install flask paramiko gunicorn

# Check if the service file exists and copy it to systemd directory
echo "Checking if service file exists at: $SERVICE_FILE_PATH"
if [ -f "$SERVICE_FILE_PATH" ]; then
    echo "Service file $SERVICE_FILE found, copying to /etc/systemd/system/"
    cp "$SERVICE_FILE_PATH" /etc/systemd/system/
    systemctl daemon-reload
    systemctl start alpha-nodes
    systemctl enable alpha-nodes
    echo "Service $SERVICE_FILE has been installed and started successfully."
else
    echo "Error: $SERVICE_FILE_PATH file not found. Please verify the path."
    exit 1
fi

echo "Installation and setup complete."
