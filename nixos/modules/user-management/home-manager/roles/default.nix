{ config, lib, pkgs, systemConfig, ... }:

{
  imports = [
    ./admin.nix
    ./guest.nix
    ./restricted-admin.nix
  ];
}