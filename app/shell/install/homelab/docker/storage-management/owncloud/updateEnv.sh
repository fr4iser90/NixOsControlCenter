#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../../../docker-scripts/lib/config.sh"
source "${SCRIPT_DIR}/../../../../docker-scripts/lib/utils.sh"

BASE_DIR="$DOCKER_BASE_DIR/storage-management/owncloud"
ENV_FILE="mysql.env"

# Validate domain
validate_domain || exit 1

# Generate MySQL root password
MYSQL_ROOT_PASSWORD=$(generate_random_string)
MYSQL_ROOT_PASSWORD_ESCAPED=$(escape_for_sed "$MYSQL_ROOT_PASSWORD")

# Debug output
echo "Generated MySQL root password: $MYSQL_ROOT_PASSWORD_ESCAPED"

# Update environment file
new_values=(
    "MYSQL_ROOT_PASSWORD:$MYSQL_ROOT_PASSWORD_ESCAPED"
    "APACHE_SERVER_NAME:$DOMAIN"
)

update_env_file "$BASE_DIR" "$ENV_FILE" "${new_values[@]}"

echo "OwnCloud environment file has been updated."
