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

# Determine the system architecture
ARCH=$(uname -m)
if [ "$ARCH" == "x86_64" ]; then
    ARCH_TYPE="amd64"
elif [ "$ARCH" == "aarch64" ]; then
    ARCH_TYPE="aarch64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Fetch the latest release URL
LATEST_RELEASE_URL=$(curl -s https://api.github.com/repos/assertAI/alpha-fleet/releases/latest | grep "browser_download_url" | grep "$ARCH_TYPE" | cut -d '"' -f 4)

if [ -z "$LATEST_RELEASE_URL" ]; then
    echo "Error: Unable to fetch the latest release URL for architecture $ARCH_TYPE."
    exit 1
fi

echo "Latest release URL: $LATEST_RELEASE_URL"

# Create necessary directories
mkdir -p /home/$USER/Documents/AlphaHB/fleetManager

# Create the txt file with the necessary details
echo "PROJECT_ID=$PROJECT_ID" > /home/$USER/Documents/AlphaHB/fleetManager/alphaDetails.txt
echo "WAREHOUSE_ID=$WAREHOUSE_ID" >> /home/$USER/Documents/AlphaHB/fleetManager/alphaDetails.txt
echo "DEVICE_ID=$DEVICE_ID" >> /home/$USER/Documents/AlphaHB/fleetManager/alphaDetails.txt

# Download the appropriate binary
echo "Downloading binary for architecture: $ARCH_TYPE"
curl -L -o /home/$USER/Documents/AlphaHB/fleetManager/alpha-fleet $LATEST_RELEASE_URL

# Give execute permissions to the binary
chmod +x /home/$USER/Documents/AlphaHB/fleetManager/alpha-fleet

# Create the systemd service file with sudo
SERVICE_FILE="/etc/systemd/system/alpha-fleet-manager.service"
echo "[Unit]
Description=Alpha Fleet Manager
After=network.target

[Service]
ExecStart=sudo /home/$USER/Documents/AlphaHB/fleetManager/alpha-fleet
WorkingDirectory=/home/$USER/Documents/AlphaHB/fleetManager
Restart=always
User=$USER
Group=$USER

[Install]
WantedBy=multi-user.target" | sudo tee $SERVICE_FILE > /dev/null

# Reload systemd, enable, and start the service with sudo
echo "Setting up service..."
sudo systemctl daemon-reload
sudo systemctl enable alpha-fleet-manager.service
sudo systemctl start alpha-fleet-manager.service

echo "Alpha Fleet Manager setup complete and running."
