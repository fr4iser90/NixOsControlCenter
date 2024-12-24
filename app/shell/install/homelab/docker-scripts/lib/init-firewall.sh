#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

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
    local bouncer_file="$DOCKER_BASE_DIR/gateway-management/traefik-crowdsec/traefik-crowdsec-bouncer.env"
    sed -i "s|^CROWDSEC_BOUNCER_API_KEY=.*|CROWDSEC_BOUNCER_API_KEY=${CROWDSEC_API_KEY}|" "$bouncer_file"
    echo "CrowdSec Bouncer configured successfully."
}

# Traefik Security Functions
init_traefik_auth() {
    echo "Configuring Traefik authentication..."
    read -p "Enter Traefik username: " TRAEFIK_USERNAME

    # Password confirmation
    while true; do
        read -sp "Enter Traefik password: " TRAEFIK_PASSWORD
        echo
        read -sp "Confirm Traefik password: " TRAEFIK_PASSWORD_CONFIRM
        echo
        [ "$TRAEFIK_PASSWORD" = "$TRAEFIK_PASSWORD_CONFIRM" ] && break
        echo "Passwords do not match. Please try again."
    done

    # Generate and update password
    local hashed_password=$(nix-shell -p apacheHttpd --run "htpasswd -nb $TRAEFIK_USERNAME '$TRAEFIK_PASSWORD' | cut -d ':' -f 2")
    local config_file="$DOCKER_BASE_DIR/gateway-management/traefik-crowdsec/traefik/dynamic_conf.yml"
    sed -i "s|\${TRAEFIKUSER}|\"$TRAEFIK_USERNAME:$hashed_password\"|g" "$config_file"
}

init_traefik_ssl() {
    if [ -z "$CERTEMAIL" ]; then
        echo "CERTEMAIL environment variable is not set" >&2
        return 1
    fi

    local config_file="$DOCKER_BASE_DIR/gateway-management/traefik-crowdsec/traefik/traefik.yml"
    sed -i "s|\${CERTEMAIL}|$CERTEMAIL|g" "$config_file"
}

# Main execution
main() {
    echo "Initializing Firewall Configuration..."

    # Initialize Traefik security
    init_traefik_auth || exit 1
    init_traefik_ssl || exit 1

    # Start Traefik with CrowdSec
    echo "Starting Traefik with CrowdSec..."
    start_docker_container "gateway-management/traefik-crowdsec"

    # Configure CrowdSec bouncer
    init_crowdsec_bouncer || exit 1

    # Restart to apply changes
    (cd "$DOCKER_BASE_DIR/gateway-management/traefik-crowdsec" && docker compose up -d --force-recreate)

    echo "Firewall configuration completed successfully."
}

main
