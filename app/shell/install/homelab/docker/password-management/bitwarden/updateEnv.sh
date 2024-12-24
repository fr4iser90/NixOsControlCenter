#!/bin/bash
source "${HOME}/docker-scripts/lib/config.sh"
source "$(get_lib_file utils.sh)"

# Get container directory
BASE_DIR=$(get_docker_dir "bitwarden")
ENV_FILE="bw.env"

# Validate domain
validate_domain || exit 1

# Get admin password and hash it
admin_password=$(prompt_password "Enter the admin password for bitwarden")
ADMIN_TOKEN=$(hash_password "$admin_password")
ADMIN_TOKEN_ESCAPED=$(escape_for_sed "$ADMIN_TOKEN")

# Update environment file
new_values=(
    "ADMIN_TOKEN:$ADMIN_TOKEN_ESCAPED"
    "DOMAIN:https://bw.$DOMAIN"
    "WEBSOCKET_ENABLED:true"
)

update_env_file "$BASE_DIR" "$ENV_FILE" "${new_values[@]}"

echo "Bitwarden environment file has been updated. AdminToken: $ADMIN_TOKEN"
