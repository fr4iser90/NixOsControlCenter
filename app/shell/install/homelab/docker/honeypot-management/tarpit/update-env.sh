#!/bin/bash

source "${DOCKER_SCRIPTS_DIR}/lib/core/imports.sh"

# Guard gegen mehrfaches Laden
if [ -n "${_PIHOLE_ENV_LOADED+x}" ]; then
    return 0
fi
_PIHOLE_ENV_LOADED=1

# Script configuration
SERVICE_NAME="pihole"
ENV_FILE="pihole.env"

BASE_DIR=$(get_docker_dir "tarpit")
ENV_FILE="grafana.env"

# Get Grafana credentials
echo "Setting up Grafana (WebInterface for tarpit/honeypot)"
read -p "Enter Grafana username: " username
password=$(prompt_password "Enter Grafana password")

# Update environment file
new_values=(
    "GF_SECURITY_ADMIN_USER:$username"
    "GF_SECURITY_ADMIN_PASSWORD:$password"
)

update_env_file "$BASE_DIR" "$ENV_FILE" "${new_values[@]}"

echo "Grafana environment file has been updated."
