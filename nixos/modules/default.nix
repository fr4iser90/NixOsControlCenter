{ config, lib, pkgs, systemConfig, ... }:

{
  imports = [
    # Core modules
    ./core/boot
    ./core/hardware
    ./core/network
    ./core/system
    ./core/user

    # Desktop environment
    ./desktop

    # Services
    ./services/cli
    ./services/homelab
    ./services/log
    ./services/ssh
    ./services/virtualization
  ];
}