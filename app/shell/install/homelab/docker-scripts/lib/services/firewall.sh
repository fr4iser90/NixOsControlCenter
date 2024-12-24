#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"
source "$(get_lib_file utils.sh)"

# CrowdSec Configuration
configure_crowdsec_bouncer() {
    echo -e "${INFO} Creating new bouncer key in CrowdSec..."
    
    local CROWDSEC_API_KEY=$(docker exec crowdsec sh -c "cscli hub update && \
                                                      cscli bouncers delete traefik-crowdsec-bouncer && \
                                                      cscli bouncers add traefik-crowsec-bouncer" | awk 'NR==3 {print $1}')

    if [ -z "$CROWDSEC_API_KEY" ]; then
        echo -e "${ERROR} Failed to generate CrowdSec bouncer API key"
        return 1
    }

    # Update bouncer configuration
    local TRAEFIK_DIR=$(get_docker_dir "traefik-crowdsec")
    update_env_file "$TRAEFIK_DIR" "traefik-crowdsec-bouncer.env" \
        "CROWDSEC_BOUNCER_API_KEY:$CROWDSEC_API_KEY"
    
    echo -e "${SUCCESS} CrowdSec Bouncer configured successfully"
}

# Traefik Security Configuration
configure_traefik_auth() {
    echo -e "${INFO} Configuring Traefik authentication..."
    
    local TRAEFIK_DIR=$(get_docker_dir "traefik-crowdsec")
    
    # Get credentials
    echo -e "${PROMPT} Enter Traefik credentials"
    local username
    username=$(prompt_input "Username" $INPUT_TYPE_NORMAL)
    local password
    password=$(prompt_input "Password" $INPUT_TYPE_SENSITIVE)

    # Generate hashed password
    local hashed_password
    hashed_password=$(nix-shell -p apacheHttpd --run "htpasswd -nb $username '$password' | cut -d ':' -f 2")
    
    # Update config
    sed -i "s|\${TRAEFIKUSER}|\"$username:$hashed_password\"|g" \
        "$TRAEFIK_DIR/traefik/dynamic_conf.yml"
        
    echo -e "${SUCCESS} Traefik authentication configured"
}

configure_traefik_ssl() {
    local TRAEFIK_DIR=$(get_docker_dir "traefik-crowdsec")
    
    if validate_email; then
        sed -i "s|\${CERTEMAIL}|$CERTEMAIL|g" "$TRAEFIK_DIR/traefik/traefik.yml"
        echo -e "${SUCCESS} SSL configuration updated"
        return 0
    fi
    return 1
}

# Main initialization function
initialize_security() {
    echo -e "${INFO} Initializing security infrastructure..."

    local TRAEFIK_DIR=$(get_docker_dir "traefik-crowdsec")

    # Update environment files
    for script in "update-crowdsec-env.sh" "update-traefik-env.sh"; do
        local script_path="$TRAEFIK_DIR/$script"
        if [ -f "$script_path" ]; then
            echo -e "${INFO} Running $script..."
            bash "$script_path" || {
                echo -e "${ERROR} Failed to run $script"
                return 1
            }
        else
            echo -e "${ERROR} Script not found: $script_path"
            return 1
        fi
    done
    
    # Configure components
    configure_traefik_auth || return 1
    configure_traefik_ssl || return 1

    # Start services
    echo -e "${INFO} Starting Traefik with CrowdSec..."
    start_docker_container "traefik-crowdsec" || return 1

    # Configure bouncer
    configure_crowdsec_bouncer || return 1

    # Restart to apply changes
    restart_docker_container "traefik-crowdsec" || return 1

    echo -e "${SUCCESS} Security infrastructure initialized successfully"
    return 0
}

initialize_security
