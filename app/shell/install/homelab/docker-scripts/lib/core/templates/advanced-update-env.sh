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
print_header "Updating SERVICE_NAME Configuration"

BASE_DIR=$(get_docker_dir "SERVICE_NAME")
ENV_FILE="SERVICE_NAME.env"
CONF_FILE="config/SERVICE_NAME.conf"

update_service_config() {
    local provider="$1"
    shift
    local vars=("$@")
    
    # Validate inputs
    validate_domain || return 1
    
    # Create directories
    mkdir -p "$BASE_DIR/config"
    
    # Get credentials
    print_status "Collecting credentials..." "info"
    local credentials=()
    for var in "${vars[@]}"; do
        local value
        value=$(prompt_password "Enter value for $var")
        credentials+=("$var=$value")
        print_status "$var: ********" "success"
    done
    
    # Update files
    if update_config_files; then
        print_status "Configuration updated" "success"
    else
        print_status "Update failed" "error"
        return 1
    fi
}

# If script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if ! update_service_config "$@"; then
        exit 1
    fi
fi