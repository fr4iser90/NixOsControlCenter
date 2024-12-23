#!/bin/bash

# Get absolute path to script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source configuration
source "$SCRIPT_DIR/lib/config.sh"

# Prevent running as root
if [ "$EUID" -eq 0 ]; then
    echo "Error: This script should NOT be run as root"
    echo "Please run as normal user who is member of the docker group"
    exit 1
fi

# Verify docker group membership
if ! groups | grep -q docker; then
    echo "Error: Current user must be in the docker group"
    echo "Run: sudo usermod -aG docker $USER"
    echo "Then log out and back in"
    exit 1
fi

# Set permissions
echo "Setting permissions..."
if ! bash "$SCRIPT_DIR/lib/set-permissions.sh"; then
    echo "Failed to set permissions. Exiting."
    exit 1
fi

# Initialize security infrastructure (Traefik & CrowdSec)
echo "Initializing security infrastructure..."
if ! bash "$SCRIPT_DIR/lib/init-firewall.sh"; then
    echo "Failed to initialize security infrastructure. Exiting."
    exit 1
fi

# Initialize all remaining services (Portainer, Plex, etc.)
echo "Initializing application services..."
if ! bash "$SCRIPT_DIR/lib/init-docker.sh"; then
    echo "Failed to initialize docker services. Exiting."
    exit 1
fi

# Success message
echo "Homelab initialization completed successfully."