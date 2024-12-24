#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../../../docker-scripts/lib/config.sh"
source "${SCRIPT_DIR}/../../../../docker-scripts/lib/utils.sh"

BASE_DIR="$DOCKER_BASE_DIR/gateway-management/traefik-crowdsec"
ENV_FILE="crowdsec.env"

# Get user info
get_user_info

# Define collections
COLLECTIONS="crowdsecurity/traefik crowdsecurity/http-cve crowdsecurity/whitelist-good-actors crowdsecurity/postfix crowdsecurity/dovecot crowdsecurity/nginx"

# Update environment file
new_values=(
    "PGID:$USER_GID"
    "COLLECTIONS:$COLLECTIONS"
)

update_env_file "$BASE_DIR" "$ENV_FILE" "${new_values[@]}"

echo "Crowdsec environment file has been updated."
