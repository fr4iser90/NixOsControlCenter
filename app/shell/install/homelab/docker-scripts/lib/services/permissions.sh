#!/bin/bash

# Standard script setup - DO NOT MODIFY
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
DOCKER_SCRIPTS_DIR="/home/docker/docker-scripts"

# Verify and source script-header
if [ ! -f "${DOCKER_SCRIPTS_DIR}/lib/core/script-header.sh" ]; then
    echo "Error: Cannot find script-header.sh"
    exit 1
fi

source "${DOCKER_SCRIPTS_DIR}/lib/core/script-header.sh"

# ==============================================
# Permission Management Functions
# ==============================================

# Set standard permissions for files and directories
set_standard_permissions() {
    local target_dir="$1"
    print_status "Setting permissions for $target_dir" "info"

    # Set base permissions
    find "$target_dir" -type d -exec chmod 755 {} \;
    find "$target_dir" -type f -exec chmod 644 {} \;

    # Make scripts executable
    find "$target_dir" -type f -name "*.sh" -exec chmod +x {} \;
}

# Set ownership for files and directories
set_ownership() {
    local target_dir="$1"
    local owner="$2"
    print_status "Setting ownership for $target_dir to $owner" "info"

    chown -R "$owner:$owner" "$target_dir"
}

# Main function to set all permissions
setup_permissions() {
    print_status "Setting up file permissions..." "info"

    # Set permissions for both directories
    set_standard_permissions "$DOCKER_BASE_DIR"
    set_standard_permissions "$DOCKER_SCRIPT_DIR"

    # Set ownership if VIRT_USER is defined
    if [ -n "$VIRT_USER" ]; then
        set_ownership "$DOCKER_BASE_DIR" "$VIRT_USER"
        set_ownership "$DOCKER_SCRIPT_DIR" "$VIRT_USER"
        print_status "File permissions and ownership set successfully!" "success"
    else
        print_status "VIRT_USER not defined, skipping ownership setup" "warning"
    fi
}