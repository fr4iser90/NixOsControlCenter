#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../../docker-scripts/lib/config.sh"
source "${SCRIPT_DIR}/../../../docker-scripts/lib/utils.sh"

BASE_DIR="$DOCKER_BASE_DIR/system-management/portainer"
COMPOSE_FILE="docker-compose.yml"

# Get user info
get_user_info

# Update compose file with user info
update_compose_file "$BASE_DIR" "$COMPOSE_FILE" "$USER_UID" "$USER_GID"

echo "Portainer Docker Compose file has been updated."
