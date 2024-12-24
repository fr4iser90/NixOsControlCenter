#!/bin/bash
source "${HOME}/docker-scripts/lib/config.sh"
source "$(get_lib_file utils.sh)"

# Get container directory
BASE_DIR=$(get_docker_dir "ddns-updater")
CONF_FILE="config/ddclient.conf"

update_dns_config() {
    local provider_code="$1"
    shift
    local vars=("$@")

    # Validate domain
    validate_domain || return 1

    # Create config directory
    mkdir -p "$BASE_DIR/config"

    echo "Updating ddclient configuration for $provider_code"
    
    # Get credentials
    local credentials=()
    for var in "${vars[@]}"; do
        local value
        value=$(prompt_password "Enter value for $var")
        credentials+=("$var=$value")
        echo "[OK] $var=********"
    done

    # Create ddclient.conf
    cat > "$BASE_DIR/$CONF_FILE" << EOF
# Configuration for $provider_code
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

    echo "DDNS configuration updated successfully"
}

# If script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Get selected provider
    selected_provider=$(select_dns_provider)
    IFS='|' read -r provider_name provider_code vars <<< "$selected_provider"
    
    update_dns_config "$provider_code" $vars
fi