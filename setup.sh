#!/bin/bash

# Function to install packages using apt
install_apt() {
    echo "Updating apt repository and installing packages..."
    sudo apt update
    sudo apt install -y python3 python3-pip
}

# Function to install packages using yum
install_yum() {
    echo "Updating yum repository and installing packages..."
    sudo yum update -y
    sudo yum install -y python3 python3-pip
}

# Function to set up a Python virtual environment and install required packages
setup_python() {
    echo "Setting up Python virtual environment..."
    cd /home/opt/NodeManagement
    python3 -m venv myenv
    source myenv/bin/activate
    pip3 install flask paramiko gunicorn
    deactivate
}

# Function to manage systemd service
manage_service() {
    echo "Reloading systemd daemon and managing alpha-nodes service..."
    sudo systemctl daemon-reload
    sudo systemctl start alpha-nodes
    sudo systemctl enable alpha-nodes
}

# Check for package manager and call appropriate function
if command -v apt-get &> /dev/null; then
    install_apt
elif command -v yum &> /dev/null; then
    install_yum
else
    echo "Unsupported package manager. Exiting."
    exit 1
fi

# Set up Python environment and manage service
setup_python
manage_service

echo "Setup complete!"

