#!/bin/bash

# Define management categories and their containers
declare -A MANAGEMENT_CATEGORIES=(
    ["adblocker-management"]="pihole"
    ["dashboard-management"]="organizr"
    ["gateway-management"]="traefik-crowdsec cloudflare-traefik-companion ddns-updater"
    ["honeypot-management"]="tarpit"
    ["media-management"]="plex jellyfin"
    ["password-management"]="bitwarden"
    ["storage-management"]="owncloud"
    ["system-management"]="portainer watchtower"
    ["url-management"]="yourls"
    ["vpn-management"]="wireguard"
)

# Helper function to get category for a container
get_container_category() {
    local container=$1
    for category in "${!MANAGEMENT_CATEGORIES[@]}"; do
        if [[ " ${MANAGEMENT_CATEGORIES[$category]} " =~ " $container " ]]; then
            echo "$category"
            return 0
        fi
    done
    return 1
}