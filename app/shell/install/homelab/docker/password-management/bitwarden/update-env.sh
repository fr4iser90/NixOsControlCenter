#!/bin/bash

# Standard script setup
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
DOCKER_SCRIPTS_DIR="/home/docker/docker-scripts"

# Source core imports
source "${DOCKER_SCRIPTS_DIR}/lib/core/imports.sh"

# Guard gegen mehrfaches Laden
if [ -n "${_BITWARDEN_ENV_LOADED+x}" ]; then
    return 0
fi
_BITWARDEN_ENV_LOADED=1

# Script configuration
SERVICE_NAME="bitwarden"
ENV_FILE="bw.env"

print_header "Updating Bitwarden Environment"

# Get service directory
BASE_DIR=$(get_docker_dir "$SERVICE_NAME")
if [ $? -ne 0 ]; then
    print_status "Failed to get $SERVICE_NAME directory" "error"
    exit 1
fi

# Validate domain
print_status "Validating domain..." "info"
if ! validate_domain; then
    print_status "Domain validation failed" "error"
    exit 1
fi

# Get admin credentials
print_status "Setting up admin credentials..." "info"
admin_password=$(prompt_input "Bitwarden admin password" $INPUT_TYPE_PASSWORD)
ADMIN_TOKEN=$(hash_password "$admin_password")
ADMIN_TOKEN_ESCAPED=$(escape_for_sed "$ADMIN_TOKEN")

# Define environment variables
new_values=(
    "ADMIN_TOKEN:$ADMIN_TOKEN_ESCAPED"
    "DOMAIN:https://bw.$DOMAIN"
    "WEBSOCKET_ENABLED:true"
)

# Update environment file
if update_env_file "$BASE_DIR" "$ENV_FILE" "${new_values[@]}"; then
    print_status "Bitwarden environment updated successfully" "success"
    print_status "AdminToken: $ADMIN_TOKEN" "info"
else
    print_status "Failed to update Bitwarden environment" "error"
    exit 1
fi