#!/bin/bash
source "${HOME}/docker-scripts/lib/config.sh"
source "$(get_lib_file utils.sh)"
source "$(get_lib_file dns/dns-providers-list.sh)"
source "$(get_lib_file dns/select-dns-provider.sh)"

# Get container directories
TRAEFIK_DIR=$(get_docker_dir "traefik-crowdsec")
DDNS_DIR=$(get_docker_dir "ddns-updater")
CLOUDFLARE_DIR=$(get_docker_dir "cloudflare-traefik-companion")

ENV_FILE="traefik.env"

# Get selected provider
selected_provider=$(select_dns_provider)
IFS='|' read -r provider_name provider_code vars <<< "$selected_provider"

# Update DDNS configuration
echo "Updating DDNS configuration..."
bash "$DDNS_DIR/update-dns-env.sh"
bash "$DDNS_DIR/update-dns-conf.sh"

# Update Cloudflare companion if selected
if [[ "$provider_code" == "cloudflare" ]]; then
    echo "Updating Cloudflare companion..."
    bash "$CLOUDFLARE_DIR/update-cloudflare-companion-env.sh"
fi

echo "Traefik environment file has been updated with $provider_name provider."
if [[ "$provider_code" == "cloudflare" ]]; then
    echo "Cloudflare companion environment file has also been updated."
fi