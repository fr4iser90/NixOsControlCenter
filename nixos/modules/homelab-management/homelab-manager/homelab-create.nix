{ config, lib, pkgs, systemConfig, ... }:

let
  homelab-create = pkgs.writeScriptBin "homelab-create" ''
    #!${pkgs.bash}/bin/bash
    
    # Farben
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    NC='\033[0m'
    
    # Hole Werte aus system-config.nix
    HOMELAB_DIR="$HOME/docker"
    HOMELAB_EMAIL="${systemConfig.email}"
    HOMELAB_DOMAIN="${systemConfig.domain}"
    HOMELAB_CERT_EMAIL="${systemConfig.certEmail}"
    VIRT_USER="$USER"
    
    echo -e "''${YELLOW}Creating new homelab environment...''${NC}"
    
    # Update domain information
    if [[ ! -d "$HOMELAB_DIR" ]]; then
        echo -e "''${RED}Docker home directory not found: $HOMELAB_DIR''${NC}"
        exit 1
    fi

    echo -e "''${YELLOW}Updating domain information...''${NC}"
    
    find "$HOMELAB_DIR" \
        -type f \( -name "*.yml" -o -name "*.env" \) \
        -exec sed -i \
            -e "s|{{EMAIL}}|$HOMELAB_EMAIL|g" \
            -e "s|{{DOMAIN}}|$HOMELAB_DOMAIN|g" \
            -e "s|{{CERTEMAIL}}|$HOMELAB_CERT_EMAIL|g" \
            -e "s|{{USER}}|$VIRT_USER|g" \
            {} \;
    
    if [ -f "$HOME/docker-scripts/init-homelab.sh" ]; then
      bash "$HOME/docker-scripts/init-homelab.sh"
    else
      echo -e "''${RED}Error: init-homelab.sh not found!''${NC}"
      echo -e "''${YELLOW}Please run homelab-fetch first''${NC}"
      exit 1
    fi
  '';

in {
  environment.systemPackages = [
    homelab-create
  ];
}