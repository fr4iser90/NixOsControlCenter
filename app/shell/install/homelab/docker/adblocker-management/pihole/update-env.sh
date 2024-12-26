#!/bin/bash

# Standard script setup
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
DOCKER_SCRIPTS_DIR="/home/docker/docker-scripts"

# Source core imports
source "${DOCKER_SCRIPTS_DIR}/lib/core/imports.sh"

# Guard gegen mehrfaches Laden
if [ -n "${_PIHOLE_ENV_LOADED+x}" ]; then
    return 0
fi
_PIHOLE_ENV_LOADED=1

# Script configuration
SERVICE_NAME="pihole"
ENV_FILE="pihole.env"

print_header "Updating Pihole Environment"

# Get service directory
BASE_DIR=$(get_docker_dir "$SERVICE_NAME")
if [ $? -ne 0 ]; then
    print_status "Failed to get $SERVICE_NAME directory" "error"
    exit 1
fi

# Set current service for credentials management
export CURRENT_SERVICE="pihole"

# Generate web password
print_status "Generating secure Pihole web password..." "info"
WEBPASSWORD=$(generate_secure_password)
if [ $? -ne 0 ]; then
    print_status "Failed to generate secure password" "error"
    exit 1
fi

# Store credentials
store_service_credentials "$SERVICE_NAME" "admin" "$WEBPASSWORD"

# Define environment variables
new_values=(
    "WEBPASSWORD:$WEBPASSWORD"
)

# Update environment file
if update_env_file "$BASE_DIR" "$ENV_FILE" "${new_values[@]}"; then
    print_status "Environment file has been updated" "success"
else
    print_status "Failed to update environment file" "error"
    exit 1
fi