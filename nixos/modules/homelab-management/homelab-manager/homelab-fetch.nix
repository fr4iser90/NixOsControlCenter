{ config, lib, pkgs, systemConfig, ... }:

let
  # Finde alle Benutzer mit virtualization Rolle
  virtUsers = lib.filterAttrs 
    (name: user: user.role == "virtualization") 
    systemConfig.users;

  # Prüfe ob wir Virtualisierungsbenutzer haben
  hasVirtUsers = (lib.length (lib.attrNames virtUsers)) > 0;

  # Hole den ersten Virtualisierungsbenutzer, falls vorhanden
  virtUser = lib.head (lib.attrNames virtUsers);

  homelab-fetch = pkgs.writeScriptBin "homelab-fetch" ''
    #!${pkgs.bash}/bin/bash
    
    # Konfiguration
    REPO_URL="https://github.com/fr4iser90/NixOsControlCenter.git"
    HOMELAB_PATH="app/shell/install/homelab"
    TEMP_DIR="/tmp/homelab-fetch"
    VIRT_HOME="/home/${virtUser}"
    CONTAINER_DIR="$VIRT_HOME/containers"
    
    # Farben
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    NC='\033[0m'
    
    # Prüfe ob der richtige User das Script ausführt
    if [ "$(whoami)" != "${virtUser}" ]; then
      echo -e "''${RED}Error: This script must be run as ${virtUser}''${NC}"
      exit 1
    fi
    
    # Rest des Scripts nur ausführen wenn als richtiger User
    echo -e "''${YELLOW}Fetching homelab configuration...''${NC}"
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"
    mkdir -p "$CONTAINER_DIR"
    
    if ! git clone --depth 1 --branch main "$REPO_URL" "$TEMP_DIR"; then
      echo -e "''${RED}Failed to clone repository!''${NC}"
      exit 1
    fi
    
    cp -r "$TEMP_DIR/$HOMELAB_PATH"/* "$VIRT_HOME/"
    
    chmod -R 755 "$CONTAINER_DIR"
    find "$CONTAINER_DIR" -type f -exec chmod 644 {} \;
    find "$CONTAINER_DIR" -type f \( -name "*.key" -o -name "*.pem" -o -name "*.crt" -o -name "*.json" \) -exec chmod 600 {} \;
    
    rm -rf "$TEMP_DIR"
    echo -e "''${GREEN}Homelab fetch completed successfully!''${NC}"
  '';

in {
  # Nur Pakete installieren wenn es einen Virtualisierungsbenutzer gibt
  environment.systemPackages = if hasVirtUsers then [
    homelab-fetch
    pkgs.git
  ] else [];
}