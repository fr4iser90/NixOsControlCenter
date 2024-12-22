# homelab-management/scripts/homelab-create.nix
{ config, lib, pkgs, ... }:

let
  homelab-create = pkgs.writeScriptBin "homelab-create" ''
    #!${pkgs.bash}/bin/bash
    
    # Farben
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    NC='\033[0m'
    
    echo -e "''${YELLOW}Creating new homelab environment...''${NC}"
    
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