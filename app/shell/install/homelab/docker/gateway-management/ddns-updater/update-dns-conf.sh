#!/bin/bash

source "${DOCKER_SCRIPTS_DIR}/lib/core/imports.sh"

# Guard gegen mehrfaches Laden
if [ -n "${_DDNS_CONFIG_LOADED+x}" ]; then
    return 0
fi
_DDNS_CONFIG_LOADED=1

# Script configuration
SERVICE_NAME="ddns-updater"
CONF_FILE="config/ddclient.conf"

print_header "Updating DDNS Configuration"

# Get service directory
BASE_DIR=$(get_docker_dir "$SERVICE_NAME")
if [ $? -ne 0 ]; then
    print_status "Failed to get $SERVICE_NAME directory" "error"
    exit 1
fi

update_dns_config() {
    local provider_code="$1"
    shift
    local vars=("$@")

    # Validate domain
    print_status "Validating domain..." "info"
    if ! validate_domain; then
        print_status "Domain validation failed" "error"
        return 1
    fi

    # Create config directory
    mkdir -p "$BASE_DIR/config"

    print_status "Updating ddclient configuration for $provider_code" "info"
    
    # Get credentials
    local credentials=()
    for var in "${vars[@]}"; do
        local value
        value=$(prompt_password "Enter value for $var")
        credentials+=("$var=$value")
        print_status "$var: ********" "success"
    done

    # Create ddclient.conf
    cat > "$BASE_DIR/$CONF_FILE" << EOF
# Configuration for $provider_code
# Generated on $(date)
daemon=300
syslog=yes
mail=root
mail-failure=root
pid=/var/run/ddclient.pid
ssl=yes

protocol=$provider_code
use=web, web=checkip.dyndns.org/, web-skip='IP Address'
${credentials[*]}
$DOMAIN
EOF

    print_status "DDNS configuration updated successfully" "success"
    return 0
}

# Run if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Get selected provider
    print_status "Selecting DNS provider..." "info"
    selected_provider=$(select_dns_provider)
    IFS='|' read -r provider_name provider_code vars <<< "$selected_provider"
    
    if ! update_dns_config "$provider_code" $vars; then
        exit 1
    fi
fi