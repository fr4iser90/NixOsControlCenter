#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../../../docker-scripts/lib/config.sh"
source "${SCRIPT_DIR}/../../../../docker-scripts/lib/utils.sh"

BASE_DIR="$DOCKER_BASE_DIR/honeypot-management/tarpit"
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
