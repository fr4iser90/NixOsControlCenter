{ config, lib, pkgs, env, ... }: 

let
  entryManager = import ../lib/entry-management/providers/systemd-boot.nix {
    inherit config lib pkgs;
  };
in
{
  # Boot loader configuration
  boot.loader = {
    # Explicitly disable GRUB
    grub.enable = lib.mkForce false;

    # systemd-boot configuration
    systemd-boot = {
      enable = true;
      configurationLimit = 15;
      editor = false;
      consoleMode = "auto";
      memtest86.enable = true;
    };

    # EFI configuration
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };

  # Activation hooks
  system.activationScripts = {
    # Initialize JSON storage
    bootEntryInit = lib.mkForce entryManager.activation.initializeJson;
    
    # Sync boot entries
    bootEntrySync = lib.mkIf config.boot.loader.systemd-boot.enable 
      (lib.mkForce entryManager.activation.syncEntries);
  };

  # Make management utilities available
  environment.systemPackages = with entryManager.scripts; [
    listEntries
    renameEntry
    resetEntry
  ];
}