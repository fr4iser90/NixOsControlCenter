# This module provides a CLI management system for NixOS.
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.cli-management;
  
  # Define categories here instead of letting modules register them
  defaultCategories = {
    vm = "Virtual Machine Management";
    net = "Network Management";
    sys = "System Management";
    # ... other categories
  };
  
  cliConfig = {
    prefix = cfg.prefix;
    categories = defaultCategories;  # Use predefined categories
  };
  
  cliTools = import ./lib/tools.nix { 
    inherit lib pkgs cliConfig;
  };
in {
  # Exportiere cliTools für andere Module
  options.cli-management = {
    enable = mkEnableOption "CLI Management";

    prefix = mkOption {
      type = types.str;
      default = "ncc";
      description = "Prefix for all CLI commands";
    };

    categories = mkOption {
      type = types.attrsOf types.str;
      default = defaultCategories;  # Use predefined categories as default
      description = "Available command categories";
    };

    tools = mkOption {
      type = types.attrs;
      default = cliTools;
      description = "CLI tools for other modules";
      internal = true;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      (cliTools.mkCommandWrapper)
    ];
  };
}