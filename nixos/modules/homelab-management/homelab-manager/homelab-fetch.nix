# homelab-management/scripts/homelab-fetch.nix
{ config, lib, pkgs, ... }:

let
  homelab-fetch = pkgs.writeScriptBin "homelab-fetch" ''
    #!${pkgs.bash}/bin/bash
    
    # Konfiguration
    REPO_URL="https://github.com/fr4iser90/NixOsControlCenter.git"
    HOMELAB_PATH="app/shell/install/homelab"
    TEMP_DIR="/tmp/homelab-fetch"
    CONFIG_FILE="/etc/nixos/system-config.nix"
    
    # Farben
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    NC='\033[0m'
    
    # Prüfe System-Typ
    if ! grep -q 'systemType = "homelab"' "$CONFIG_FILE"; then
      echo -e "''${RED}Error: This system is not configured as homelab''${NC}"
      echo -e "''${YELLOW}Current configuration in $CONFIG_FILE:''${NC}"
      grep 'systemType = ' "$CONFIG_FILE"
      exit 1
    fi
    
    # Prüfe ob User virtualization Rolle hat
    if ! groups | grep -q "docker"; then
      echo -e "''${RED}Error: User must be in docker group''${NC}"
      exit 1
    fi
    
    # Temporäres Verzeichnis erstellen und Repository klonen
    echo -e "''${YELLOW}Fetching homelab configuration...''${NC}"
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"
    
    if ! git clone --depth 1 --branch main "$REPO_URL" "$TEMP_DIR"; then
      echo -e "''${RED}Failed to clone repository!''${NC}"
      exit 1
    fi
    
    # Homelab Dateien kopieren
    echo -e "''${YELLOW}Installing homelab to $HOME...''${NC}"
    cp -r "$TEMP_DIR/$HOMELAB_PATH"/* "$HOME/"
    
    # Berechtigungen setzen
    echo -e "''${YELLOW}Setting permissions...''${NC}"
    chmod -R 755 "$HOME/docker"  # Verzeichnisse
    find "$HOME/docker" -type f -exec chmod 644 {} \;  # Normale Dateien
    
    # Sensitive Dateien schützen
    echo -e "''${YELLOW}Protecting sensitive files...''${NC}"
    find "$HOME/docker" -type f \( -name "*.key" -o -name "*.pem" -o -name "*.crt" -o -name "*.json" \) -exec chmod 600 {} \;
    
    # Aufräumen
    rm -rf "$TEMP_DIR"
    
    echo -e "''${GREEN}Homelab fetch completed successfully!''${NC}"
  '';

in {
  environment.systemPackages = [
    homelab-fetch
    pkgs.git
  ];
}