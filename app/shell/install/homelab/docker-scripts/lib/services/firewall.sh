#!/bin/bash

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
DOCKER_SCRIPTS_DIR="/home/docker/docker-scripts"

source "${DOCKER_SCRIPTS_DIR}/lib/core/imports.sh"

# Guard gegen mehrfaches Laden
if [ -n "${_SECURITY_SERVICE_LOADED+x}" ]; then
    return 0
fi
_SECURITY_SERVICE_LOADED=1

# ==============================================
# Security Functions
# ==============================================

# CrowdSec Configuration
configure_crowdsec_bouncer() {
    print_status "Creating new bouncer key in CrowdSec..." "info"
    
    local CROWDSEC_API_KEY=$(docker exec crowdsec sh -c "cscli hub update && \
                                                      cscli bouncers delete traefik-crowdsec-bouncer && \
                                                      cscli bouncers add traefik-crowsec-bouncer" | awk 'NR==3 {print $1}')

    if [ -z "$CROWDSEC_API_KEY" ]; then
        print_status "Failed to generate CrowdSec bouncer API key" "error"
        return 1
    fi

    # Update bouncer configuration
    local TRAEFIK_DIR=$(get_docker_dir "traefik-crowdsec")
    update_env_file "$TRAEFIK_DIR" "traefik-crowdsec-bouncer.env" \
        "CROWDSEC_BOUNCER_API_KEY:$CROWDSEC_API_KEY"
    
    print_status "CrowdSec Bouncer configured successfully" "success"
}

# Traefik Security Configuration
configure_traefik_auth() {
    print_header "Configuring Traefik Authentication"
    
    local TRAEFIK_DIR=$(get_docker_dir "traefik-crowdsec")
    
    # Get credentials with better prompts
    print_prompt "Traefik Dashboard Access"
    print_status "These credentials will be used to access the Traefik dashboard" "info"
    echo

    # USERNAME
    print_status "Step 1: Create Username" "info"
    print_status "Choose a username for the dashboard login" "info"
    echo
    
    local username
    print_status "Enter username" "input"
    echo -e -n "${CYAN}Username${NC} > "
    read username
    echo

    # PASSWORD
    print_status "Step 2: Create Password" "info"
    print_status "Choose a secure password for the dashboard login" "info"
    print_status "Password requirements:" "info"
    print_status "- Minimum 8 characters" "info"
    print_status "- At least one number" "info"
    print_status "- At least one special character" "info"
    echo
    
    local password
    print_status "Enter password" "input"
    echo -e -n "${CYAN}Password${NC} > "
    read -s password
    echo
    print_status "Confirm password" "input"
    echo -e -n "${CYAN}Confirm${NC} > "
    read -s password2
    echo

    if [ "$password" != "$password2" ]; then
        print_status "Passwords do not match!" "error"
        return 1
    fi

    print_status "Password validated" "success"
    print_status "Generating secure password hash..." "info"
    
    # Generate hashed password
    local hashed_password
    hashed_password=$(nix-shell -p apacheHttpd --command "htpasswd -nbB \"$username\" \"$password\"" | cut -d ':' -f 2)
    
    if [ -z "$hashed_password" ]; then
        print_status "Failed to generate password hash" "error"
        return 1
    fi
    
    # Update config
    sed -i "s|\${TRAEFIKUSER}|\"$username:$hashed_password\"|g" \
        "$TRAEFIK_DIR/traefik/dynamic_conf.yml"
        
    print_status "Traefik authentication configured successfully" "success"
    print_status "You can now login with:" "info"
    print_status "Username: $username" "info"
    echo
    return 0
}

configure_traefik_ssl() {
    local TRAEFIK_DIR=$(get_docker_dir "traefik-crowdsec")
    
    if validate_email; then
        sed -i "s|\${CERTEMAIL}|$CERTEMAIL|g" "$TRAEFIK_DIR/traefik/traefik.yml"
        print_status "SSL configuration updated" "success"
        return 0
    fi
    return 1
}

# Main initialization function
initialize_security() {
    print_status "Initializing security infrastructure..." "info"

    local TRAEFIK_DIR=$(get_docker_dir "traefik-crowdsec")

    # DNS Setup MUSS ZUERST kommen!
    print_status "Setting up DNS configuration..." "info"
    if ! update_dns_configuration; then
        print_status "Failed to configure DNS" "error"
        return 1
    fi

    # Update environment files
    for script in "update-crowdsec-env.sh" "update-traefik-env.sh"; do
        local script_path="$TRAEFIK_DIR/$script"
        if [ -f "$script_path" ]; then
            print_status "Running $script..." "info"
            bash "$script_path" || {
                print_status "Failed to run $script" "error"
                return 1
            }
        else
            print_status "Script not found: $script_path" "error"
            return 1
        fi
    done
    
    # Configure components
    configure_traefik_auth || return 1
    configure_traefik_ssl || return 1

    # Start services
    print_status "Starting Traefik with CrowdSec..." "info"
    start_docker_container "traefik-crowdsec" || return 1

    # Configure bouncer
    configure_crowdsec_bouncer || return 1

    # Restart to apply changes
    restart_docker_container "traefik-crowdsec" || return 1

    print_status "Security infrastructure initialized successfully" "success"
    return 0
}
