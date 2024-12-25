#!/bin/bash
source "${HOME}/docker-scripts/lib/config.sh"
source "$(get_lib_file utils.sh)"

# Get container directory
BASE_DIR=$(get_docker_dir "owncloud")
ENV_FILE="mysql.env"

# Validate domain
validate_domain || exit 1

# Generate MySQL root password
MYSQL_ROOT_PASSWORD=$(generate_random_string)

# Debug output
echo "Generated MySQL root password: $MYSQL_ROOT_PASSWORD"

# Update environment file
new_values=(
    "MYSQL_ROOT_PASSWORD:$MYSQL_ROOT_PASSWORD"
    "APACHE_SERVER_NAME:$DOMAIN"
)

update_env_file "$BASE_DIR" "$ENV_FILE" "${new_values[@]}"

echo "OwnCloud environment file has been updated."
