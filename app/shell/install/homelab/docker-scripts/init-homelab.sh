#!/bin/bash

# Source configuration
source "$(dirname "${BASH_SOURCE[0]}")/lib/config.sh"

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Initialize security infrastructure (Traefik & CrowdSec)
echo "Initializing security infrastructure..."
if ! bash "$(dirname "${BASH_SOURCE[0]}")/lib/init-firewall.sh"; then
    echo "Failed to initialize security infrastructure. Exiting."
    exit 1
fi

# Initialize all remaining services (Portainer, Plex, etc.)
echo "Initializing application services..."
if ! bash "$(dirname "${BASH_SOURCE[0]}")/lib/init-docker.sh"; then
    echo "Failed to initialize docker services. Exiting."
    exit 1
fi

# Success message
echo "Homelab initialization completed successfully."