#!/bin/bash

# Accept arguments from the command line passed via 'bash -s'
PROJECT_ID=$1
WAREHOUSE_ID=$2
DEVICE_ID=$3

# Check if all arguments are provided
if [ -z "$PROJECT_ID" ] || [ -z "$WAREHOUSE_ID" ] || [ -z "$DEVICE_ID" ]; then
    echo "Error: Missing arguments. Please provide PROJECT_ID, WAREHOUSE_ID, and DEVICE_ID."
    exit 1
fi

# Create necessary directories
mkdir -p /home/$USER/Documents/AlphaHB/fleetManager

# Create the txt file with the necessary details
echo "Project ID: $PROJECT_ID" > /home/$USER/Documents/AlphaHB/fleetManager/alphaDetails.txt
echo "Warehouse ID: $WAREHOUSE_ID" >> /home/$USER/Documents/AlphaHB/fleetManager/alphaDetails.txt
echo "Device ID: $DEVICE_ID" >> /home/$USER/Documents/AlphaHB/fleetManager/alphaDetails.txt

# Download the binary
echo "Downloading binary..."
curl -L -o /home/$USER/Documents/AlphaHB/fleetManager/alpha-fleet-aarch64 https://github.com/assertAI/alpha-fleet/releases/download/v0.1.0/alpha-fleet-aarch64

# Give execute permissions to the binary
chmod +x /home/$USER/Documents/AlphaHB/fleetManager/alpha-fleet-aarch64

# Create the systemd service file
SERVICE_FILE="/etc/systemd/system/alpha-fleet-manager.service"
echo "[Unit]
Description=Alpha Fleet Manager
After=network.target

[Service]
ExecStart=/home/$USER/Documents/AlphaHB/fleetManager/alpha-fleet-aarch64
WorkingDirectory=/home/$USER/Documents/AlphaHB/fleetManager
Restart=always
User=$USER
Group=$USER

[Install]
WantedBy=multi-user.target" > $SERVICE_FILE

# Reload systemd, enable, and start the service
systemctl daemon-reload
systemctl enable alpha-fleet-manager.service
systemctl start alpha-fleet-manager.service

echo "Alpha Fleet Manager setup complete and running."
