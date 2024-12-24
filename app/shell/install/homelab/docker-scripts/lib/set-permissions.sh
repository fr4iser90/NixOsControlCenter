#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

echo "Setting sensitive file permissions..."

# Make all scripts executable
find "$DOCKER_BASE_DIR" -type f -name "*.sh" -exec chmod +x {} \;
find "$DOCKER_SCRIPT_DIR" -type f -name "*.sh" -exec chmod +x {} \;

# Set directory permissions
find "$DOCKER_BASE_DIR" -type d -exec chmod 755 {} \;
find "$DOCKER_SCRIPT_DIR" -type d -exec chmod 755 {} \;

# Set file permissions
find "$DOCKER_BASE_DIR" -type f -exec chmod 644 {} \;
find "$DOCKER_SCRIPT_DIR" -type f -exec chmod 644 {} \;

# Make scripts executable again (after setting 644)
find "$DOCKER_BASE_DIR" -type f -name "*.sh" -exec chmod +x {} \;
find "$DOCKER_SCRIPT_DIR" -type f -name "*.sh" -exec chmod +x {} \;

# Set ownership
chown -R "$VIRT_USER:$VIRT_USER" "$DOCKER_BASE_DIR"
chown -R "$VIRT_USER:$VIRT_USER" "$DOCKER_SCRIPT_DIR"

echo "File permissions set successfully!"