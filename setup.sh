#!/bin/bash
# Variables
USERNAME="snb-tech"
PASSWORD="Sanem25-AUG1999"

# Create user if not exists
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists."
else
    sudo useradd -m $USERNAME
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

# Unzip the NodeManagement.zip file

sudo unzip NodeManagement.zip -d /opt/

sleep 1
# Navigate to the NodeManagement directory
cd /opt/NodeManagement

# Create a virtual environment and install required Python packages
python3 -m venv myenv
source myenv/bin/activate
pip3 install flask paramiko gunicorn

# Copy the service file and manage the service
sudo cp -r alpha-nodes.service /etc/systemd/system/alpha-nodes.service
sudo systemctl daemon-reload
sudo systemctl start alpha-nodes
sudo systemctl enable alpha-nodes

echo "Installation and setup complete."
