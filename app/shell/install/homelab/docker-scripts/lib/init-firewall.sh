#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"
source "$(get_lib_file utils.sh)"

# Get container directory using helper function
TRAEFIK_CROWDSEC_BASE_DIR=$(get_docker_dir "traefik-crowdsec")

# Firewall Configuration Functions
init_crowdsec_bouncer() {
    echo "Creating new bouncer key in CrowdSec..."
    CROWDSEC_API_KEY=$(docker exec crowdsec sh -c "cscli hub update && \
                                                  cscli bouncers delete traefik-crowdsec-bouncer && \
                                                  cscli bouncers add traefik-crowsec-bouncer" | awk 'NR==3 {print $1}')

    if [ -z "$CROWDSEC_API_KEY" ]; then
        echo "Failed to generate CrowdSec bouncer API key" >&2
        return 1
    fi

    # Update bouncer configuration
    new_values=(
        "CROWDSEC_BOUNCER_API_KEY:$CROWDSEC_API_KEY"
    )
    update_env_file "$TRAEFIK_CROWDSEC_BASE_DIR" "traefik-crowdsec-bouncer.env" "${new_values[@]}"
    echo "CrowdSec Bouncer configured successfully."
}

# Traefik Security Functions
init_traefik_auth() {
    echo "Configuring Traefik authentication..."
    read -p "Enter Traefik username: " TRAEFIK_USERNAME
    TRAEFIK_PASSWORD=$(prompt_password "Enter Traefik password")

    # Generate and update password
    local hashed_password=$(nix-shell -p apacheHttpd --run "htpasswd -nb $TRAEFIK_USERNAME '$TRAEFIK_PASSWORD' | cut -d ':' -f 2")
    sed -i "s|\${TRAEFIKUSER}|\"$TRAEFIK_USERNAME:$hashed_password\"|g" "$TRAEFIK_CROWDSEC_BASE_DIR/traefik/dynamic_conf.yml"
}

init_traefik_ssl() {
    validate_email || return 1
    sed -i "s|\${CERTEMAIL}|$CERTEMAIL|g" "$TRAEFIK_CROWDSEC_BASE_DIR/traefik/traefik.yml"
}

# Main execution
main() {
    echo "Initializing Firewall Configuration..."

    # Update environment files
    echo "Running environment updates..."
    for script in "update-crowdsec-env.sh" "update-traefik-env.sh"; do
        local script_path="$TRAEFIK_CROWDSEC_BASE_DIR/$script"
        if [ -f "$script_path" ]; then
            echo "Running $script..."
            bash "$script_path" || {
                echo "Failed to run $script" >&2
                return 1
            }
        else
            echo "Error: Script not found: $script_path" >&2
            ls -la "$TRAEFIK_CROWDSEC_BASE_DIR"  # Debug output
            return 1
        fi
    done
    
    # Initialize Traefik security
    init_traefik_auth || exit 1
    init_traefik_ssl || exit 1

    # Start Traefik with CrowdSec
    echo "Starting Traefik with CrowdSec..."
    start_docker_container "traefik-crowdsec" || exit 1

    # Configure CrowdSec bouncer
    init_crowdsec_bouncer || exit 1

    # Restart to apply changes
    restart_docker_container "traefik-crowdsec" || exit 1

    echo "Firewall configuration completed successfully."
}

main
