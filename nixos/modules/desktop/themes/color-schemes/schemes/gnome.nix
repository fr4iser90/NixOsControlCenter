{ config, lib, pkgs, systemConfig, ... }:
{
  config = lib.mkIf (systemConfig.desktop.environment == "gnome") {
    services.xserver = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    programs.dconf.enable = true;
    programs.dconf.profiles.user.databases = [{
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = if systemConfig.desktop.theme.dark then "prefer-dark" else "default";
          gtk-theme = if systemConfig.desktop.theme.dark then "Adwaita-dark" else "Adwaita";
        };
      };
    }];
    
    # Korrigierte Theme-Pakete
    environment.systemPackages = with pkgs; [
      adwaita-icon-theme  
      gtk-engine-murrine
    ];
  };
}