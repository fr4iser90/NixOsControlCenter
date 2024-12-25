#!/bin/bash

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
DOCKER_SCRIPTS_DIR="/home/docker/docker-scripts"

source "${DOCKER_SCRIPTS_DIR}/lib/core/imports.sh"

# Guard gegen mehrfaches Laden
if [ -n "${_SERVICES_INIT_LOADED+x}" ]; then
    return 0
fi
_SERVICES_INIT_LOADED=1

# Service Initialization
initialize_services() {
    print_header "Optional Services Setup"

    # Prüfe ob FZF verfügbar ist
    if ! command -v fzf >/dev/null 2>&1; then
        print_status "FZF is not installed. Please install it first." "error"
        return 1
    }

    # Erstelle Service-Liste für FZF
    local services=()
    local descriptions=()
    for category in "${!MANAGEMENT_CATEGORIES[@]}"; do
        # Überspringe Gateway-Management, da bereits installiert
        if [ "$category" != "gateway-management" ]; then
            for service in ${MANAGEMENT_CATEGORIES[$category]}; do
                services+=("$category:$service")
                # Hole Service-Beschreibung aus README wenn vorhanden
                local readme="${DOCKER_BASE_DIR}/${category}/${service}/README.md"
                if [ -f "$readme" ]; then
                    descriptions+=("$(head -n 1 "$readme" | sed 's/^#\s*//')")
                else
                    descriptions+=("$service")
                fi
            done
        fi
    done

    # FZF Multi-Select mit Preview
    print_status "Select services to install (SPACE to select, ENTER to confirm):" "info"
    local selected
    selected=$(printf '%s\n' "${services[@]}" | fzf --multi \
        --header 'Use SPACE to select/unselect services, ENTER to confirm' \
        --preview 'echo {} | cut -d: -f2 | xargs -I% sh -c '\''
            cat "'"${DOCKER_BASE_DIR}"'/$(echo {} | cut -d: -f1)/%/README.md" 2>/dev/null || 
            echo "No description available for %"
        '\'' \
        --preview-window=right:50%)

    if [ -z "$selected" ]; then
        print_status "No services selected" "warn"
        return 0
    fi

    # Installiere ausgewählte Services
    while IFS= read -r selection; do
        local category="${selection%%:*}"
        local service="${selection#*:}"
        
        print_status "Initializing $service..." "info"
        
        # Update Environment
        local service_dir="${DOCKER_BASE_DIR}/${category}/${service}"
        if [ -f "${service_dir}/update-env.sh" ]; then
            bash "${service_dir}/update-env.sh" || {
                print_status "Failed to update environment for $service" "error"
                return 1
            }
        fi

        # Starte Container
        start_docker_container "$service" || {
            print_status "Failed to start $service" "error"
            return 1
        }

        print_status "$service initialized successfully" "success"
    done <<< "$selected"

    print_status "All selected services have been initialized" "success"
    return 0
}

# Run if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    initialize_services
fi