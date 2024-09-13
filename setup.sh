#!/bin/bash

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
unzip NodeManagement.zip -d /home/opt/NodeManagement

# Navigate to the NodeManagement directory
cd /home/opt/NodeManagement

# Create a virtual environment and install required Python packages
python3 -m venv myenv
source myenv/bin/activate
pip3 install flask paramiko gunicorn

# Copy the service file and manage the service
sudo cp -r /home/opt/NodeManagement/alpha-nodes.service /etc/systemd/system/alpha-nodes.service
sudo systemctl daemon-reload
sudo systemctl start alpha-nodes
sudo systemctl enable alpha-nodes

echo "Installation and setup complete."
