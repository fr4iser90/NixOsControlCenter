# src/nixos/nixconfig/users/default.nix
{ config, pkgs, lib, systemConfig, ... }:

let
  # Gruppen basierend auf Rolle
  roleGroups = {
    admin = [ "wheel" "networkmanager" "docker" "video" "audio" "render" "input" "seat" ];
    guest = [ "networkmanager" ];
    restricted-admin = [ "wheel" "networkmanager" "video" "audio" ];
  };

  # Sudo-Regeln basierend auf Rolle
  makeSudoRules = username: role: 
    if role == "admin" then [{
      users = [ username ];
      commands = [{
        command = "ALL";
        options = if systemConfig.sudo.requirePassword or true
          then [ "PASSWD" ]
          else [ "NOPASSWD" ];
      }];
    }]
    else if role == "restricted-admin" then [{
      users = [ username ];
      commands = [{
        command = "ALL";
        options = [ "PASSWD" ];
      }];
    }]
    else [];  # Keine sudo-Rechte für andere Rollen

in {
  # Basis-Konfiguration für alle Benutzer
  users.mutableUsers = false;
  
  # Aktiviere die Shells auf System-Level
  programs = {
    zsh.enable = lib.any (user: systemConfig.users.${user}.defaultShell == "zsh") 
      (builtins.attrNames systemConfig.users);
    fish.enable = lib.any (user: systemConfig.users.${user}.defaultShell == "fish") 
      (builtins.attrNames systemConfig.users);
  };
  
  # Benutzer aus systemConfig.users erstellen
  users.users = lib.mapAttrs (username: userConfig: {
    isNormalUser = true;
    home = "/home/${username}";
    shell = pkgs.${userConfig.defaultShell};
    hashedPasswordFile = if userConfig.role == "admin" 
      then "/etc/nixos/secrets/passwords/.hashedLoginPassword"
      else null;
    extraGroups = roleGroups.${userConfig.role};
  }) systemConfig.users;

  # Sudo-Konfiguration
  security.sudo = {
    enable = true;
    extraRules = lib.concatLists (lib.mapAttrsToList 
      (username: userConfig: makeSudoRules username userConfig.role)
      systemConfig.users
    );
  };

  # TTY-Konfiguration
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
}