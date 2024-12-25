#!/bin/bash
source "${HOME}/docker-scripts/lib/config.sh"
source "$(get_lib_file utils.sh)"

# Get container directory
BASE_DIR=$(get_docker_dir "wireguard")
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
