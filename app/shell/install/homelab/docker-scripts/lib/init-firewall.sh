#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

# Function to create a new bouncer key
create_bouncer_key() {
  docker exec crowdsec sh -c "cscli hub update"
  docker exec crowdsec sh -c "cscli bouncers delete traefik-crowdsec-bouncer"
  local key=$(docker exec crowdsec sh -c "cscli bouncers add traefik-crowsec-bouncer" | awk 'NR==3 {print $1}')
  echo "$key"
}

# Function to start docker container in a given directory
start_docker_container() {
  local container=$1
  local docker_dir="$DOCKER_BASE_DIR/$container"

  # Check if updateEnv.sh exists and execute it
  if [ -f "$docker_dir/updateEnv.sh" ]; then
    echo "Executing updateEnv.sh in $container"
    (cd "$docker_dir" && bash updateEnv.sh)
  fi

  if [ -d "$docker_dir" ]; then
    echo "Starting docker-compose in $container"
    (cd "$docker_dir" && docker compose up -d)
  else
    echo "Directory $container does not exist in $DOCKER_BASE_DIR"
  fi
}

# Function to handle traefik-crowdsec specific operations
handle_traefik_crowdsec() {
  echo "Creating new bouncer key in CrowdSec..."
  CROWDSEC_API_KEY=$(create_bouncer_key)

  if [ -z "$CROWDSEC_API_KEY" ]; then
    echo "Failed to generate CrowdSec bouncer API key" >&2
    exit 1
  fi

  echo "New CrowdSec Bouncer Token: $CROWDSEC_API_KEY. Routes should now be protected by CrowdSec."

  # Updating traefik-crowdsec-bouncer.env with new API key
  BOUNCER_ENV_FILE="$DOCKER_BASE_DIR/traefik-crowdsec/traefik-crowdsec-bouncer.env"
  sed -i "s|^CROWDSEC_BOUNCER_API_KEY=.*|CROWDSEC_BOUNCER_API_KEY=${CROWDSEC_API_KEY}|" "$BOUNCER_ENV_FILE"

  echo "Restarting Traefik container..."
  (cd "$DOCKER_BASE_DIR/traefik-crowdsec" && docker compose up -d --force-recreate)
}

# Function to replace CERTEMAIL in traefik.yml
update_traefik_certemail() {
  local traefik_file="$DOCKER_BASE_DIR/traefik-crowdsec/traefik/traefik.yml"
  if [ -f "$traefik_file" ]; then
    echo "Updating CERTEMAIL in $traefik_file"
    sed -i "s|\${CERTEMAIL}|$CERTEMAIL|g" "$traefik_file"
  else
    echo "File $traefik_file does not exist" >&2
    exit 1
  fi
}

# Function to update Traefik user in dynamic_conf.yml
update_traefik_user() {
  local traefik_file="$DOCKER_BASE_DIR/traefik-crowdsec/traefik/dynamic_conf.yml"
  local traefik_user="$1"
  local hashed_password="$2"
  
  if [ -f "$traefik_file" ]; then
    echo "Updating TRAEFIKUSER in $traefik_file"
    sed -i "s|\${TRAEFIKUSER}|\"$traefik_user:$hashed_password\"|g" "$traefik_file"
  else
    echo "File $traefik_file does not exist" >&2
    exit 1
  fi
}

# Main script
echo "Traefik should be protected with authentication. Please enter a username and password to generate a hashed password, which will be added to dynamic_conf.yml. Alternatively, you can update it manually if preferred."
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

# Generate hashed password using nix-shell and htpasswd
HASHED_PASSWORD=$(nix-shell -p apacheHttpd --run "htpasswd -nb $TRAEFIK_USERNAME '$TRAEFIK_PASSWORD' | cut -d ':' -f 2")

# Update Traefik user in dynamic_conf.yml
update_traefik_user "$TRAEFIK_USERNAME" "$HASHED_PASSWORD"

# Check if CERTEMAIL is set
if [ -z "$CERTEMAIL" ]; then
  echo "CERTEMAIL environment variable is not set" >&2
  exit 1
fi

# Update CERTEMAIL in traefik.yml before starting docker-compose
update_traefik_certemail

# Start docker container for traefik-crowdsec and handle specific operations
start_docker_container "traefik-crowdsec"
handle_traefik_crowdsec

echo "Traefik and CrowdSec setup completed."