#!/bin/bash

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
DOCKER_SCRIPTS_DIR="/home/docker/docker-scripts"

# Source core imports
source "${DOCKER_SCRIPTS_DIR}/lib/core/imports.sh"

# Get container directory
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
