#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/dns-providers-list.sh"

# Provider Select Function
# Returns: "provider_name|provider_code|env_vars"
# Example: "Cloudflare|cloudflare|CF_API_EMAIL CF_ZONE_ID CF_API_KEY"
select_dns_provider() {
    # Check for fzf and install if needed
    if ! command -v fzf &> /dev/null; then
        echo "fzf is not installed. Installing fzf..."
        nix-env -iA nixos.fzf || {
            echo "Failed to install fzf. Exiting."
            return 1
        }
    fi

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
        echo "No provider selected. Exiting." >&2
        return 1
    fi
}

# NEUE FUNKTION für die Credentials-Abfrage
get_dns_credentials() {
    local selected_provider=$(select_dns_provider)
    if [ $? -ne 0 ]; then
        return 1
    fi

    # Split provider info
    IFS='|' read -r provider_name provider_code provider_vars <<< "$selected_provider"
    
    # Declare associative array for credentials
    declare -A credentials
    
    # Get credentials for each variable
    for var in $provider_vars; do
        echo "Setting up $var..."
        credentials[$var]=$(prompt_password "Enter value for $var")
        # Export als Environment Variable
        export "$var=${credentials[$var]}"
    done

    # Export provider info
    export DNS_PROVIDER_NAME="$provider_name"
    export DNS_PROVIDER_CODE="$provider_code"
    
    echo "Credentials configured for $provider_name"
    return 0
}