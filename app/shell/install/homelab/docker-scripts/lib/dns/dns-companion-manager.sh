#!/bin/bash

if [ -n "${_DNS_COMPANION_MANAGER_LOADED+x}" ]; then
    return 0
fi
_DNS_COMPANION_MANAGER_LOADED=1

# Traefik Companion Konfiguration direkt hier!
declare -ga TRAEFIK_COMPANIONS=(
    "cloudflare:cloudflare-traefik-companion"  
)

# Der Pfad muss zum gateway-management Ordner
TRAEFIK_COMPANIONS_DIR="gateway-management"    


update_companion_config() {
    local provider_code="$1"
    
    for companion in "${TRAEFIK_COMPANIONS[@]}"; do
        IFS=':' read -r comp_provider comp_name <<< "$companion"
        
        if [[ "$provider_code" == "$comp_provider" ]]; then
            print_status "Updating Traefik $comp_name companion..." "info"
            
            local COMPANION_DIR=$(get_docker_dir "$TRAEFIK_COMPANIONS_DIR/$comp_name")
            
            if ! bash "$COMPANION_DIR/update-env.sh"; then
                print_status "Failed to update $comp_name companion" "error"
                return 1
            fi
            print_status "Traefik $comp_name companion updated" "success"
            return 0
        fi
    done
    
    return 0  # Kein Companion = kein Fehler
}