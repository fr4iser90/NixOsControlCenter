#!/bin/bash

# Standard script setup - DO NOT MODIFY
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
DOCKER_SCRIPTS_DIR="/home/docker/docker-scripts"

# Verify and source script-header
if [ ! -f "${DOCKER_SCRIPTS_DIR}/lib/core/script-header.sh" ]; then
    echo "Error: Cannot find script-header.sh"
    exit 1
fi

source "${DOCKER_SCRIPTS_DIR}/lib/core/script-header.sh"

# ==============================================
# DNS Provider Selection Functions
# ==============================================

# Provider Select Function
# Returns: "provider_name|provider_code|env_vars"
# Example: "Cloudflare|cloudflare|CF_API_EMAIL CF_ZONE_ID CF_API_KEY"
select_dns_provider() {
    # Check for fzf and install if needed
    if ! command -v fzf &> /dev/null; then
        print_status "fzf is not installed. Installing fzf..." "info"
        nix-env -iA nixos.fzf || {
            print_status "Failed to install fzf" "error"
            return 1
        }
    }

    # Use fzf for interactive provider selection
    local selected
    selected=$(printf "%s\n" "${providers[@]}" | \
        fzf --prompt="Select your DNS provider: " \
            --delimiter=" " \
            --header="Provider Name | Code | Required Environment Variables" \
            --preview 'echo "Selected: {1}\nCode: {2}\nRequired Env Vars: {3..}"')

    # Process selection
    if [ -n "$selected" ]; then
        local provider_name provider_code vars
        provider_name=$(echo "$selected" | awk '{print $1}')
        provider_code=$(echo "$selected" | awk '{print $2}')
        vars=$(echo "$selected" | awk '{for(i=3;i<=NF;i++) printf $i " "; print ""}')
        
        echo "$provider_name|$provider_code|$vars"
        return 0
    else
        print_status "No provider selected" "error"
        return 1
    fi
}

# Get DNS credentials
get_dns_credentials() {
    local selected_provider=$(select_dns_provider)
    if [ $? -ne 0 ]; then
        return 1
    }

    # Split provider info
    IFS='|' read -r provider_name provider_code provider_vars <<< "$selected_provider"
    
    # Declare associative array for credentials
    declare -A credentials
    
    print_status "Configuring credentials for $provider_name" "info"
    
    # Get credentials for each variable
    for var in $provider_vars; do
        print_status "Setting up $var..." "info"
        credentials[$var]=$(prompt_password "Enter value for $var")
        # Export als Environment Variable
        export "$var=${credentials[$var]}"
    done

    # Export provider info
    export DNS_PROVIDER_NAME="$provider_name"
    export DNS_PROVIDER_CODE="$provider_code"
    
    print_status "Credentials configured for $provider_name" "success"
    return 0
}