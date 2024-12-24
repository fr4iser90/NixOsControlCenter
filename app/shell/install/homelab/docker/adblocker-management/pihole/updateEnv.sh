#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../../../docker-scripts/lib/config.sh"
source "${SCRIPT_DIR}/../../../../docker-scripts/lib/utils.sh"

BASE_DIR="$DOCKER_BASE_DIR/adblocker-management/pihole"
ENV_FILE="pihole.env"

# Generate web password
echo "Generating a secure Pihole web password..."
WEBPASSWORD=$(generate_random_string)

# Update environment file
new_values=(
    "WEBPASSWORD:$WEBPASSWORD"
)

update_env_file "$BASE_DIR" "$ENV_FILE" "${new_values[@]}"

echo "Pihole environment file has been updated."
