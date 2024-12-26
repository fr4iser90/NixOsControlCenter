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
    fi

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

    # Erstelle temporäre Preview-Funktion
    preview_service() {
        local selection="$1"
        local category="${selection%%:*}"
        local service="${selection#*:}"
        local readme="${DOCKER_BASE_DIR}/${category}/${service}/README.md"
        
        if [ -f "$readme" ]; then
            cat "$readme"
        else
            echo "No description available for $service"
        fi
    }
    export -f preview_service

    local selected
    selected=$(printf '%s\n' "${services[@]}" | fzf --multi \
        --header='Use SPACE to deselect services, ENTER to confirm' \
        --bind 'space:toggle+down' \
        --bind 'tab:toggle' \
        --bind 'ctrl-a:toggle-all' \
        --preview 'bash -c "preview_service {}"' \
        --preview-window="right:50%:wrap" \
        --pointer="▶" \
        --marker="✓" \
        --reverse \
        --bind 'start:select-all')

    if [ -z "$selected" ]; then
        print_status "No services selected" "warn"
        return 0
    fi

    # Installiere ausgewählte Services
    local failed_services=()
    while IFS= read -r selection; do
        local category="${selection%%:*}"
        local service="${selection#*:}"
        
        print_status "Initializing $service..." "info"
        
        # Setze CURRENT_SERVICE für Auto-Credentials
        export CURRENT_SERVICE="$service"
        
        # Update Environment
        local service_dir="${DOCKER_BASE_DIR}/${category}/${service}"
        if [ -f "${service_dir}/update-env.sh" ]; then
            if ! bash "${service_dir}/update-env.sh"; then
                print_status "Failed to update environment for $service - skipping" "warn"
                failed_services+=("$service")
                continue
            fi
        fi

        # Starte Container
        if ! start_docker_container "$service"; then
            print_status "Failed to start $service - skipping" "warn"
            failed_services+=("$service")
            continue
        fi

        print_status "$service initialized successfully" "success"
    done <<< "$selected"

    # Zeige Zusammenfassung
    if [ ${#failed_services[@]} -gt 0 ]; then
        print_status "Some services failed to initialize:" "warn"
        for service in "${failed_services[@]}"; do
            print_status "- $service" "warn"
        done
        print_status "You can try to initialize these services later with: homelab-service install <service>" "info"
    else
        print_status "All selected services have been initialized" "success"
    fi

    # Finalisiere Credentials wenn Auto-Setup aktiv war
    if [ "$AUTO_SETUP" -eq 1 ]; then
        finalize_credentials_file
    fi

    return 0
}

# Run if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    initialize_services
fi