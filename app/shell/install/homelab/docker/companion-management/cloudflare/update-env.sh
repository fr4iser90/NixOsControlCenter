#!/bin/bash

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
DOCKER_SCRIPTS_DIR="/home/docker/docker-scripts"

source "${DOCKER_SCRIPTS_DIR}/lib/core/imports.sh"

if [ -n "${_CLOUDFLARE_COMPANION_LOADED+x}" ]; then
    return 0
fi
_CLOUDFLARE_COMPANION_LOADED=1

print_header "Updating Cloudflare Companion Configuration"

# Validate domain
print_status "Validating domain..." "info"
if ! validate_domain; then
    print_status "Domain validation failed" "error"
    exit 1
fi

# Get current directory
SERVICE_NAME="cloudflare"
ENV_FILE="cloudflare-companion.env"

BASE_DIR=$(get_docker_dir "$SERVICE_NAME")
if [ $? -ne 0 ]; then
    print_status "Failed to get $SERVICE_NAME directory" "error"
    exit 1
fi

# Verwende die bereits vorhandenen Umgebungsvariablen
print_status "Using existing Cloudflare credentials..." "info"

# Update environment file
new_values=(
    "CF_EMAIL:$CF_API_EMAIL"
    "CF_API_KEY:$CF_API_KEY"
    "DOMAIN1_ZONE_ID:$CF_ZONE_ID"
    "TARGET_DOMAIN:$DOMAIN"
    "DOMAIN1:$DOMAIN"
)

if update_env_file "$BASE_DIR" "$ENV_FILE" "${new_values[@]}"; then
    print_status "Cloudflare configuration updated successfully" "success"
    exit 0
else
    print_status "Failed to update Cloudflare configuration" "error"
    exit 1
fi