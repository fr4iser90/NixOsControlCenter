#!/bin/bash

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
DOCKER_SCRIPTS_DIR="/home/docker/docker-scripts"
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

# Generate web password
print_status "Generating secure Pihole web password..." "info"
WEBPASSWORD=$(generate_random_string)

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