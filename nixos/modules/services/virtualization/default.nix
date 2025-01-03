{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.virtualisation.management;
in {
  imports = [
    (import ./testing { inherit config lib pkgs; })
  ];

  options.virtualisation.management = {
    enable = mkEnableOption "Virtualization Management";
    storage.enable = mkEnableOption "Storage Management for Virtualization";
    stateDir = mkOption {
      type = types.path;
      default = "/var/lib/virt";
      description = "Base directory for virtualization state";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.virtualisation.management.storage.enable;
        message = "Storage management must be enabled for virtualization management";
      }
      {
        assertion = config.cli-management.enable;
        message = "CLI management must be enabled for virtualization management";
      }
    ];

    # Base requirements
    virtualisation = {
      libvirtd.enable = true;
  #    libvirtd.qemu.enable = true;
  #    libvirtd.qemu.package = pkgs.qemu_kvm;
      libvirtd.allowedBridges = [ "virbr0" ];
      spiceUSBRedirection.enable = true;
    };


    programs.virt-manager.enable = true;

    # Base packages
    environment.systemPackages = with pkgs; [
      qemu
      virt-manager
      spice
      spice-gtk
      spice-protocol
 #     OVMF
      swtpm
    ];

    # Base directory structure
    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0755 root root -"
      "d ${cfg.stateDir}/images 0775 root libvirt -"
      "d ${cfg.stateDir}/testing 0775 root libvirt -"
    ];

    # Enable components
    virtualisation.management.storage.enable = true;

    # Register VM category
    
  };
}