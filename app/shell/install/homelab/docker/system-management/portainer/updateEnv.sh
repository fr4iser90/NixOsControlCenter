#!/bin/bash
source "${HOME}/docker-scripts/lib/config.sh"
source "$(get_lib_file utils.sh)"

# Get container directory
BASE_DIR=$(get_docker_dir "portainer")
COMPOSE_FILE="docker-compose.yml"

# Get user info
get_user_info

# Update compose file with user info
update_compose_file "$BASE_DIR" "$COMPOSE_FILE" "$USER_UID" "$USER_GID"

echo "Portainer Docker Compose file has been updated."
