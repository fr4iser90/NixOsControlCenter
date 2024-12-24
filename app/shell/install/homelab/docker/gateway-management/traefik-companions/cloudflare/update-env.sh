#!/bin/bash

source "${DOCKER_SCRIPTS_DIR}/lib/core/imports.sh"

# Guard gegen mehrfaches Laden
if [ -n "${_CLOUDFLARE_COMPANION_LOADED+x}" ]; then
    return 0
fi
_CLOUDFLARE_COMPANION_LOADED=1

# Script configuration
SERVICE_NAME="cloudflare-traefik-companion"
ENV_FILE="cloudflare-companion.env"

print_header "Updating Cloudflare Companion Configuration"

# Get service directory
BASE_DIR=$(get_docker_dir "$SERVICE_NAME")
if [ $? -ne 0 ]; then
    print_status "Failed to get $SERVICE_NAME directory" "error"
    exit 1
fi

update_cloudflare_companion() {
    local provider="$1"
    shift
    local vars=("$@")
    
    # Only proceed for Cloudflare
    if [[ "$provider" != "cloudflare" ]]; then
        print_status "Not a Cloudflare provider, skipping" "info"
        return 0
    fi
    
    # Validate domain
    print_status "Validating domain..." "info"
    if ! validate_domain; then
        print_status "Domain validation failed" "error"
        return 1
    fi
    
    # Create directory
    mkdir -p "$BASE_DIR"
    
    # Initialize env file with domain info
    print_status "Initializing environment file..." "info"
    cat > "$BASE_DIR/$ENV_FILE" << EOF
TARGET_DOMAIN=$DOMAIN
DOMAIN1=$DOMAIN
EOF
    
    # Handle Cloudflare variables
    print_status "Collecting Cloudflare credentials..." "info"
    local new_values=()
    for var in "${vars[@]}"; do
        local value
        value=$(prompt_password "Enter value for $var")
        
        case "$var" in
            "CF_API_EMAIL")
                new_values+=("CF_EMAIL:$value")
                print_status "Email configured" "success"
                ;;
            "CF_API_KEY")
                new_values+=("CF_API_KEY:$value")
                print_status "API Key configured" "success"
                ;;
            "CF_ZONE_ID")
                new_values+=("DOMAIN1_ZONE_ID:$value")
                print_status "Zone ID configured" "success"
                ;;
        esac
    done
    
    # Update env file
    print_status "Updating environment file..." "info"
    if update_env_file "$BASE_DIR" "$ENV_FILE" "${new_values[@]}"; then
        print_status "Cloudflare configuration updated successfully" "success"
        return 0
    else
        print_status "Failed to update Cloudflare configuration" "error"
        return 1
    fi
}

# Run if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if ! update_cloudflare_companion "cloudflare" "CF_API_EMAIL" "CF_API_KEY" "CF_ZONE_ID"; then
        exit 1
    fi
fi