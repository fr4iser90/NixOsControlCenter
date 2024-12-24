#!/bin/bash

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