#!/bin/bash

# Standard script setup
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
DOCKER_SCRIPTS_DIR="/home/docker/docker-scripts"

# Verify and source script-header
if [ ! -f "${DOCKER_SCRIPTS_DIR}/lib/core/script-header.sh" ]; then
    echo "Error: Cannot find script-header.sh"
    echo "Expected at: ${DOCKER_SCRIPTS_DIR}/lib/core/script-header.sh"
    exit 1
fi

source "${DOCKER_SCRIPTS_DIR}/lib/core/script-header.sh"

# Script logic
print_header "Updating Portainer Configuration"

# Get container directory
BASE_DIR=$(get_docker_dir "portainer")
if [ $? -ne 0 ]; then
    print_status "Failed to get portainer directory" "error"
    exit 1
fi

COMPOSE_FILE="docker-compose.yml"

# Get user info
print_status "Getting user information..." "info"
if ! get_user_info; then
    print_status "Failed to get user information" "error"
    exit 1
fi

# Update compose file
print_status "Updating Docker Compose file..." "info"
if update_compose_file "$BASE_DIR" "$COMPOSE_FILE" "$USER_UID" "$USER_GID"; then
    print_status "Portainer Docker Compose file has been updated" "success"
else
    print_status "Failed to update Docker Compose file" "error"
    exit 1
fi