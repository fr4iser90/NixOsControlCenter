#!/bin/bash

# Get absolute path to script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

# Containers that should be skipped (already handled by init-firewall.sh)
EXCEPT=("gateway-management/traefik-crowdsec")

# Function to initialize a single docker container
initialize_docker() {
    local category=$1
    local container=$2
    local docker_dir="$DOCKER_BASE_DIR/$category/$container"
    
    echo "Processing $category/$container..."
    
    # Check if updateEnv.sh exists and execute it
    if [ -f "$docker_dir/updateEnv.sh" ]; then
        echo "Executing updateEnv.sh for $container"
        (cd "$docker_dir" && bash updateEnv.sh)
    fi
    
    # Start docker-compose
    echo "Starting docker-compose for $container"
    (cd "$docker_dir" && docker compose up -d)
}

# Function to print service access information
print_service_info() {
    echo "Docker initialization completed successfully."
    echo
    echo "You can now access the following services:"
    
    # System Management
    echo "System Management:"
    echo "- Portainer: https://portainer.${DOMAIN}"
    
    # Media Management
    echo "Media Management:"
    echo "- Plex: https://plex.${DOMAIN}"
    echo "- Jellyfin: https://jellyfin.${DOMAIN}"
    
    # Dashboard Management
    echo "Dashboard Management:"
    echo "- Organizr: https://organizr.${DOMAIN}"
    
    # Storage Management
    echo "Storage Management:"
    echo "- OwnCloud: https://owncloud.${DOMAIN}"
    
    echo
    echo "Don't forget to:"
    echo "1. Complete the Portainer installation"
    echo "2. Set up Organizr"
    echo "3. Configure OwnCloud"
    echo "4. Claim your Plex server"
}

# Main execution
main() {
    echo "Initializing docker containers..."

    # Process all management categories
    for category in "${!MANAGEMENT_CATEGORIES[@]}"; do
        echo "Processing $category..."
        
        # Get containers for this category
        IFS=' ' read -ra containers <<< "${MANAGEMENT_CATEGORIES[$category]}"
        
        for container in "${containers[@]}"; do
            # Skip excluded containers
            if [[ " ${EXCEPT[@]} " =~ " $category/$container " ]]; then
                echo "Skipping $category/$container (handled separately)"
                continue
            fi
            
            initialize_docker "$category" "$container"
        done
    done

    # Print service information
    print_service_info

    # Handle Plex claim token if needed
    if [ -d "$DOCKER_BASE_DIR/media-management/plex" ]; then
        echo "Updating Plex claim token..."
        (cd "$DOCKER_BASE_DIR/media-management/plex" && bash updateClaim.sh)
    fi
}

# Execute main function
main