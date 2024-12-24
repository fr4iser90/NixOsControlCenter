#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../../../docker-scripts/lib/config.sh"
source "${SCRIPT_DIR}/../../../../docker-scripts/lib/utils.sh"

BASE_DIR="$DOCKER_BASE_DIR/vpn-management/wireguard"
ENV_FILE="wireguard.env"

# Get WireGuard credentials
read -p "Enter WireGuard Username: " username
password=$(prompt_password "Enter WireGuard Password")

# Update environment file
new_values=(
    "WGUI_USERNAME:$username"
    "WGUI_PASSWORD:$password"
)

update_env_file "$BASE_DIR" "$ENV_FILE" "${new_values[@]}"

echo "WireGuard environment file has been updated successfully."
