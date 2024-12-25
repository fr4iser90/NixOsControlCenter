#!/bin/bash
source "${HOME}/docker-scripts/lib/config.sh"
source "$(get_lib_file utils.sh)"

# Get container directory
BASE_DIR=$(get_docker_dir "plex")
ENV_FILE="plex.env"

# Function to prompt the user for the PLEX_CLAIM token
prompt_claim_token() {
    echo "Please open https://plex.${DOMAIN}/claim and copy the token"
    read -p "Enter the new PLEX_CLAIM token: " PLEX_CLAIM
    echo "$PLEX_CLAIM"
}

# Get the PLEX_CLAIM token
PLEX_CLAIM=$(prompt_claim_token)

# Update environment file
new_values=(
    "PLEX_CLAIM:$PLEX_CLAIM"
)

update_env_file "$BASE_DIR" "$ENV_FILE" "${new_values[@]}"

echo "Plex claim token has been updated: $PLEX_CLAIM"
