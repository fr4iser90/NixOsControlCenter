#!/bin/bash

# Standard script setup
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
DOCKER_SCRIPTS_DIR="/home/docker/docker-scripts"

# Source core imports
source "${DOCKER_SCRIPTS_DIR}/lib/core/imports.sh"

# Guard gegen mehrfaches Laden
if [ -n "${_WIREGUARD_ENV_LOADED+x}" ]; then
    return 0
fi
_WIREGUARD_ENV_LOADED=1

# Script configuration
SERVICE_NAME="wireguard"
ENV_FILE="wireguard.env"

print_header "Updating WireGuard Environment"

# Get service directory
BASE_DIR=$(get_docker_dir "$SERVICE_NAME")
if [ $? -ne 0 ]; then
    print_status "Failed to get $SERVICE_NAME directory" "error"
    exit 1
fi

# Set current service for credentials management
export CURRENT_SERVICE="wireguard"

# Get WireGuard credentials
print_status "Setting up WireGuard credentials..." "info"

# Username eingabe
username=$(prompt_input "WireGuard username" $INPUT_TYPE_USERNAME)
if [ $? -ne 0 ]; then
    print_status "Failed to get username" "error"
    exit 1
fi
export CURRENT_USERNAME="$username"

# Password eingabe
password=$(prompt_input "WireGuard password" $INPUT_TYPE_PASSWORD)
if [ $? -ne 0 ]; then
    print_status "Failed to get password" "error"
    exit 1
fi

# Store credentials
store_service_credentials "$SERVICE_NAME" "$username" "$password"

# Define environment variables
new_values=(
    "WGUI_USERNAME:$username"
    "WGUI_PASSWORD:$password"
)

# Update environment file
if update_env_file "$BASE_DIR" "$ENV_FILE" "${new_values[@]}"; then
    print_status "WireGuard environment updated successfully" "success"
    if [ "$SHOW_CREDENTIALS" = true ]; then
        print_status "Username: $username" "info"
    fi
else
    print_status "Failed to update WireGuard environment" "error"
    exit 1
fi