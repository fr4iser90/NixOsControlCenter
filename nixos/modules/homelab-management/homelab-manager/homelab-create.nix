{ config, lib, pkgs, systemConfig, ... }:

let
  # Finde Virtualisierungsbenutzer
  virtUsers = lib.filterAttrs 
    (name: user: user.role == "virtualization") 
    systemConfig.users;
  hasVirtUsers = (lib.length (lib.attrNames virtUsers)) > 0;
  virtUser = lib.head (lib.attrNames virtUsers);

  homelab-create = pkgs.writeScriptBin "homelab-create" ''
    #!${pkgs.bash}/bin/bash
    
    # Farben
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    NC='\033[0m'
    
    # Konfiguration
    VIRT_USER="${virtUser}"
    VIRT_HOME="/home/$VIRT_USER"
    CONTAINER_DIR="$VIRT_HOME/docker"
    HOMELAB_EMAIL="${systemConfig.email}"
    HOMELAB_DOMAIN="${systemConfig.domain}"
    HOMELAB_CERT_EMAIL="${systemConfig.certEmail}"
    
    # Prüfe ob der richtige User das Script ausführt
    if [ "$(whoami)" != "$VIRT_USER" ]; then
      echo -e "''${RED}Error: This script must be run as $VIRT_USER''${NC}"
      exit 1
    fi
    
    echo -e "''${YELLOW}Creating new homelab environment...''${NC}"
    
    # Prüfe ob Container-Verzeichnis existiert
    if [[ ! -d "$CONTAINER_DIR" ]]; then
        echo -e "''${RED}Container directory not found: $CONTAINER_DIR''${NC}"
        echo -e "''${YELLOW}Please run homelab-fetch first''${NC}"
        exit 1
    fi

    echo -e "''${YELLOW}Updating configuration files...''${NC}"
    
    # Update Konfigurationsdateien
    find "$CONTAINER_DIR" \
        -type f \( -name "*.yml" -o -name "*.env" \) \
        -exec sed -i \
            -e "s|{{EMAIL}}|$HOMELAB_EMAIL|g" \
            -e "s|{{DOMAIN}}|$HOMELAB_DOMAIN|g" \
            -e "s|{{CERTEMAIL}}|$HOMELAB_CERT_EMAIL|g" \
            -e "s|{{USER}}|$VIRT_USER|g" \
            {} \;
    
    # Führe Init-Script aus, falls vorhanden
    INIT_SCRIPT="$CONTAINER_DIR/scripts/init-homelab.sh"
    if [ -f "$INIT_SCRIPT" ]; then
      echo -e "''${YELLOW}Running initialization script...''${NC}"
      bash "$INIT_SCRIPT"
      echo -e "''${GREEN}Homelab environment created successfully!''${NC}"
    else
      echo -e "''${RED}Error: init-homelab.sh not found!''${NC}"
      echo -e "''${YELLOW}Please run homelab-fetch first''${NC}"
      exit 1
    fi
  '';

in {
  # Nur installieren wenn es einen Virtualisierungsbenutzer gibt
  environment.systemPackages = if hasVirtUsers then [
    homelab-create
  ] else [];
}