#!/bin/bash

# Base paths
export DOCKER_BASE_DIR="${HOME}/homelab/docker"
export DOCKER_SCRIPT_DIR="${HOME}/homelab/docker-scripts"

# Validate DOMAIN environment variable
if [ -z "$DOMAIN" ]; then
    echo "ERROR: DOMAIN environment variable is not set"
    exit 1
fi

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
