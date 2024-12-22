#!/bin/bash

# Get absolute path to script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

# Docker containers that should be skipped (already handled by init-firewall.sh)
EXCEPT=("traefik-crowdsec")

# Function to initialize a single docker container
initialize_docker() {
    local docker_dir=$1
    local docker_name=$(basename "$docker_dir")
    
    echo "Processing docker container: $docker_name"
    
    # Check if updateEnv.sh exists and execute it
    if [ -f "$docker_dir/updateEnv.sh" ]; then
        echo "Executing updateEnv.sh in $docker_name"
        (cd "$docker_dir" && bash updateEnv.sh)
    fi
    
    # Start docker-compose
    echo "Starting docker-compose in $docker_name"
    (cd "$docker_dir" && docker compose up -d)
}

# Main execution
echo "Initializing docker containers..."

# Process all containers in the docker directory
for docker_dir in "$DOCKER_BASE_DIR"/*; do
    docker_name=$(basename "$docker_dir")
    
    # Skip excluded containers
    if [[ " ${EXCEPT[@]} " =~ " ${docker_name} " ]]; then
        echo "Skipping $docker_name (handled separately)"
        continue
    fi

    # Process only directories
    if [ -d "$docker_dir" ]; then
        initialize_docker "$docker_dir"
    fi
done

# Post-initialization messages
echo "Docker initialization completed successfully."
echo
echo "You can now access the following services:"
echo "- Portainer: https://portainer.${DOMAIN}"
echo "- Plex: https://plex.${DOMAIN}"
echo "- Organizr: https://organizer.${DOMAIN}"
echo "- OwnCloud: https://owncloud.${DOMAIN}"
echo
echo "Don't forget to:"
echo "1. Complete the Portainer installation"
echo "2. Set up Organizr"
echo "3. Configure OwnCloud"
echo "4. Claim your Plex server"

# Handle Plex claim token
if [ -d "$DOCKER_BASE_DIR/plex" ]; then
    echo "Updating Plex claim token..."
    (cd "$DOCKER_BASE_DIR/plex" && bash updateClaim.sh)
fi