#!/bin/bash

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