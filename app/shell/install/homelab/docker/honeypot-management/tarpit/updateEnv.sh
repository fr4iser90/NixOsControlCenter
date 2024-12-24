#!/bin/bash
source "${HOME}/docker-scripts/lib/config.sh"
source "$(get_lib_file utils.sh)"

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
