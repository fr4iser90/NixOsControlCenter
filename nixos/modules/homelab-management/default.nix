{ config, lib, pkgs, systemConfig, ... }:

{
  imports = [
    ./homelab-manager
#    ./container-manager
  ];

  # Gemeinsame Konfiguration für alle Homelab-Scripts
  options.homelab = {
    enable = lib.mkEnableOption "Enable homelab management";
    user = lib.mkOption {
      type = lib.types.str;
      default = "docker";
      description = "User who manages the homelab";
    };
  };
}