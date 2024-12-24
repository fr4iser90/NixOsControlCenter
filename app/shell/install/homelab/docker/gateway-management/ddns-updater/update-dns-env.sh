#!/bin/bash
source "${HOME}/docker-scripts/lib/config.sh"
source "$(get_lib_file utils.sh)"

# Get container directory
BASE_DIR=$(get_docker_dir "ddns-updater")
ENV_FILE="ddns-updater.env"

# Get user info
get_user_info

# Update environment file
new_values=(
    "PUID:$USER_UID"
    "PGID:$USER_GID"
)

update_env_file "$BASE_DIR" "$ENV_FILE" "${new_values[@]}"

echo "DDNS environment file has been updated."