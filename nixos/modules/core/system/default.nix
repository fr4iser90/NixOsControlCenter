{ config, lib, pkgs, systemConfig, ... }:
{
  imports = 
    lib.optional (systemConfig.preflightChecks or false) ./preflight
    ++ lib.optional (systemConfig.postflightChecks or false) ./postflight
    ++ lib.optional (systemConfig.flakeUpdater or false) ./update;

  config = {
    environment.systemPackages = with pkgs; [
      pciutils
      usbutils
      lshw
    ];
  };
}