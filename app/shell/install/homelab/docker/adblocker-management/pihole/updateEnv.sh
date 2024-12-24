#!/bin/bash
source "${HOME}/docker-scripts/lib/config.sh"
source "$(get_lib_file utils.sh)"

# Get container directory
BASE_DIR=$(get_docker_dir "pihole")
ENV_FILE="pihole.env"

# Generate web password
echo "Generating a secure Pihole web password..."
WEBPASSWORD=$(generate_random_string)

# Update environment file
new_values=(
    "WEBPASSWORD:$WEBPASSWORD"
)

update_env_file "$BASE_DIR" "$ENV_FILE" "${new_values[@]}"

echo "Pihole environment file has been updated."
