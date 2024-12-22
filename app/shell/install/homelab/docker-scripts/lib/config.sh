#!/bin/bash

# Get the absolute path to the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Get parent directory of docker-scripts
BASE_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Base paths relative to where the script actually is
export DOCKER_BASE_DIR="${BASE_DIR}/docker"
export DOCKER_SCRIPT_DIR="${BASE_DIR}/docker-scripts"

# Docker container directories
declare -A DOCKER_CONTAINERS=(
    [bitwarden]="bitwarden"
    [jellyfin]="jellyfin"
    [organizr]="organizr"
    [owncloud]="owncloud"
    [pihole]="pihole"
    [plex]="plex"
    [portainer]="portainer"
    [tarpit]="tarpit"
    [traefik]="traefik-crowdsec"
    [watchtower]="watchtower"
    [wireguard]="wireguard"
    [yourls]="yourls"
)


get_docker_dir() {
    local container=$1
    echo "$DOCKER_BASE_DIR/${DOCKER_CONTAINERS[$container]}"
}
