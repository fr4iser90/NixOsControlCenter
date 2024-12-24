#!/bin/bash

# Standard script setup - DO NOT MODIFY
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
DOCKER_SCRIPTS_DIR="/home/docker/docker-scripts"

# Source core imports
source "${DOCKER_SCRIPTS_DIR}/lib/core/imports.sh"

# ==============================================
# EDIT BELOW THIS LINE
# ==============================================

# Get container directories
TRAEFIK_DIR=$(get_docker_dir "traefik-crowdsec")
DDNS_DIR=$(get_docker_dir "ddns-updater")
CLOUDFLARE_DIR=$(get_docker_dir "cloudflare-traefik-companion")

print_header "DNS Configuration Setup"

# Main update function
update_dns_configuration() {
    # 1. Select DNS provider first
    local selected_provider=$(select_dns_provider)
    if [ $? -ne 0 ]; then
        print_status "DNS provider selection failed" "error"
        return 1
    fi

    # 2. Save provider info
    IFS=' ' read -r provider_name provider_code provider_vars <<< "$selected_provider"
    export DNS_PROVIDER_NAME="$provider_name"
    export DNS_PROVIDER_CODE="$provider_code"

    # 3. Get and save credentials
    if ! get_dns_credentials "$selected_provider"; then
        print_status "Failed to get DNS credentials" "error"
        return 1
    fi

    # 4. Update configurations
    print_status "Updating DDNS configuration..." "info"
    if ! update_ddns_config; then
        print_status "Failed to update DDNS configuration" "error"
        return 1
    fi

    # 5. Handle Cloudflare specific setup
    if [[ "$DNS_PROVIDER_CODE" == "cloudflare" ]]; then
        print_status "Updating Cloudflare companion..." "info"
        if ! update_cloudflare_config; then
            print_status "Failed to update Cloudflare configuration" "error"
            return 1
        fi
    fi

    print_status "DNS configuration completed with $DNS_PROVIDER_NAME provider" "success"
    [[ "$DNS_PROVIDER_CODE" == "cloudflare" ]] && \
        print_status "Cloudflare companion configuration updated" "success"

    return 0
}

# Update DDNS configuration
update_ddns_config() {
    bash "$DDNS_DIR/update-dns-env.sh" && \
    bash "$DDNS_DIR/update-dns-conf.sh"
}

# Update Cloudflare configuration
update_cloudflare_config() {
    bash "$CLOUDFLARE_DIR/update-cloudflare-companion-env.sh"
}

# Run if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Initialize DNS configuration
    update_dns_configuration || exit 1
fi