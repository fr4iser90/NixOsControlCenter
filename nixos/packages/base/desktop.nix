{ config, lib, pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    coreutils
    curl
    wget
    git
    neovim
    htop
    tmux
    tree
    fzf
    bottles-unwrapped
  ];
}