#!/bin/bash
source "${HOME}/docker-scripts/lib/config.sh"
source "$(get_lib_file utils.sh)"

# Get container directory
BASE_DIR=$(get_docker_dir "cloudflare-traefik-companion")
ENV_FILE="cloudflare-companion.env"

update_cloudflare_companion() {
    local provider="$1"
    shift
    local vars=("$@")
    
    [[ "$provider" != "cloudflare" ]] && return 0
    
    # Validate domain
    validate_domain || return 1
    
    # Create/update companion env file
    local companion_env="$BASE_DIR/$ENV_FILE"
    mkdir -p "$BASE_DIR"
    
    # Initialize env file with domain info
    cat > "$companion_env" << EOF
TARGET_DOMAIN=$DOMAIN
DOMAIN1=$DOMAIN
EOF
    
    # Handle Cloudflare variables
    local new_values=()
    for var in "${vars[@]}"; do
        local value
        value=$(prompt_password "Enter value for $var")
        
        case "$var" in
            "CF_API_EMAIL")
                new_values+=("CF_EMAIL:$value")
                ;;
            "CF_API_KEY")
                new_values+=("CF_API_KEY:$value")
                ;;
            "CF_ZONE_ID")
                new_values+=("DOMAIN1_ZONE_ID:$value")
                ;;
        esac
    done
    
    # Update env file
    update_env_file "$BASE_DIR" "$ENV_FILE" "${new_values[@]}"
}