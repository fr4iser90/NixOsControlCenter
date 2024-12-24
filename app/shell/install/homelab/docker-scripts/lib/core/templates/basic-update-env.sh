#!/bin/bash

# Standard script setup
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
DOCKER_SCRIPTS_DIR="/home/docker/docker-scripts"

# Verify and source script-header
if [ ! -f "${DOCKER_SCRIPTS_DIR}/lib/core/script-header.sh" ]; then
    echo "Error: Cannot find script-header.sh"
    exit 1
fi

source "${DOCKER_SCRIPTS_DIR}/lib/core/script-header.sh"

# Script logic
print_header "Updating SERVICE_NAME Environment"

BASE_DIR=$(get_docker_dir "SERVICE_NAME")
ENV_FILE="SERVICE_NAME.env"

new_values=(
    "KEY1:VALUE1"
    "KEY2:VALUE2"
)

if update_env_file "$BASE_DIR" "$ENV_FILE" "${new_values[@]}"; then
    print_status "Environment updated" "success"
else
    print_status "Update failed" "error"
    exit 1
fi