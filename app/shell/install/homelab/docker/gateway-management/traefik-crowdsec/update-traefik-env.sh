#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../../docker-scripts/lib/config.sh"
source "${SCRIPT_DIR}/../../../docker-scripts/lib/utils.sh"
source "${SCRIPT_DIR}/../../../docker-scripts/lib/dns/dns-providers-list.sh"
source "${SCRIPT_DIR}/../../../docker-scripts/lib/dns/select-dns-provider.sh"
source "${SCRIPT_DIR}/../ddns-updater/update-dns-env.sh"
source "${SCRIPT_DIR}/../cloudflare-traefik-companion/update-cloudflare-companion-env.sh"

BASE_DIR="$DOCKER_BASE_DIR/gateway-management/traefik-crowdsec"
ENV_FILE="traefik.env"

# Get selected provider
selected_provider=$(select_dns_provider)
IFS='|' read -r provider_name provider_code vars <<< "$selected_provider"

# Update traefik env
update_dns_env "$provider_code" $vars

# Update companion env if cloudflare
if [[ "$provider_code" == "cloudflare" ]]; then
    update_cloudflare_companion "$provider_code" $vars
fi

echo "Traefik environment file has been updated with $provider_name provider."
if [[ "$provider_code" == "cloudflare" ]]; then
    echo "Cloudflare companion environment file has also been updated."
fi