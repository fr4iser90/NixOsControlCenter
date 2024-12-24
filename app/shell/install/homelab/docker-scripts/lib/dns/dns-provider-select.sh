#!/bin/bash

# Guard gegen mehrfaches Laden
if [ -n "${_DNS_PROVIDER_SELECT_LOADED+x}" ]; then
    return 0
fi
_DNS_PROVIDER_SELECT_LOADED=1

# ==============================================
# DNS Provider Selection Functions
# ==============================================

select_dns_provider() {
    print_status "Available DNS providers:" "info"
    
    # Create numbered list of providers
    local i=1
    local provider_list=()
    
    for provider in "${providers[@]}"; do
        IFS=' ' read -r name code _ <<< "$provider"
        echo "  $i) $name"
        provider_list+=("$provider")
        ((i++))
    done
    
    # Get user selection
    local selection
    while true; do
        selection=$(prompt_input "Select DNS provider (1-$((i-1)))" $INPUT_TYPE_NORMAL)
        if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le $((i-1)) ]; then
            break
        fi
        print_status "Invalid selection. Please try again." "error"
    done
    
    # Return selected provider
    echo "${provider_list[$((selection-1))]}"
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