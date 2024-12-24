#!/bin/bash

# Get the absolute path to the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Get parent directory of docker-scripts
BASE_DIR="${HOME}"

# Base paths relative to where the script actually is
export DOCKER_BASE_DIR="${BASE_DIR}/docker"
export DOCKER_SCRIPT_DIR="${BASE_DIR}/docker-scripts"

# Management categories and their containers
declare -A MANAGEMENT_CATEGORIES=(
    [gateway-management]="traefik-crowdsec cloudflare-traefik-companion ddns-updater"
    [security-management]="crowdsec tarpit wireguard"
    [system-management]="portainer watchtower"
    [media-management]="jellyfin plex"
    [storage-management]="owncloud"
    [password-management]="bitwarden"
    [dashboard-management]="organizr"
    [url-management]="yourls"
    [adblocker-management]="pihole"
)

# Function to get the full path to a container
get_docker_dir() {
    local container=$1
    
    # Search through management categories
    for category in "${!MANAGEMENT_CATEGORIES[@]}"; do
        if [[ " ${MANAGEMENT_CATEGORIES[$category]} " =~ " $container " ]]; then
            echo "$DOCKER_BASE_DIR/$category/$container"
            return 0
        fi
    done
    
    echo "Container $container not found in any management category" >&2
    return 1
}

# Function to get all containers in a management category
get_category_containers() {
    local category=$1
    echo "${MANAGEMENT_CATEGORIES[$category]}"
}

# Function to get the management category of a container
get_container_category() {
    local container=$1
    
    for category in "${!MANAGEMENT_CATEGORIES[@]}"; do
        if [[ " ${MANAGEMENT_CATEGORIES[$category]} " =~ " $container " ]]; then
            echo "$category"
            return 0
        fi
    done
    
    echo "Category not found for container $container" >&2
    return 1
}
