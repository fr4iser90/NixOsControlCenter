#!/bin/bash

# Get absolute path to script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

# Function to set sensitive file permissions
set_sensitive_permissions() {
    log_info "Setting sensitive file permissions..."
    
    # Find and set permissions for sensitive files
    find "$HOME/docker" \
        -type f \( -name "*.key" -o -name "*.pem" -o -name "*.crt" \) \
        -exec chmod 600 {} \;
    
    # Handle Traefik/Crowdsec certificates
    local traefik_certs=(
        "$HOME/docker/traefik-crowdsec/traefik/acme_letsencrypt.json"
        "$HOME/docker/traefik-crowdsec/traefik/tls_letsencrypt.json"
    )
    
    for cert in "${traefik_certs[@]}"; do
        if [[ -f "$cert" ]]; then
            log_debug "Setting permissions for $cert"
            chmod 600 "$cert"
        fi
    done
    
    log_success "Sensitive file permissions set successfully!"
    return 0
}

# Main execution
set_sensitive_permissions