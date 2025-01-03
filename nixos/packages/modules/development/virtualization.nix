# development/virtualization.nix
{ config, lib, pkgs, ... }:
{
    imports = [../../../modules/services/virtualization];


    environment.systemPackages = with pkgs; [
      # GUI Tools
      virt-viewer    # SPICE/VNC clients
      virt-manager   # Grafische Verwaltung von VMs
      
      # CLI Tools
      qemu          # QEMU selbst
      spice-vdagent
      spice-gtk     # SPICE client libraries
      
      # Netzwerk Tools
      bridge-utils  # Für Netzwerk-Bridges
      wget         # Für ISO Downloads
      
      # Debugging Tools
      socat        # Für QEMU Monitor
      lsof         # Für Port-Debugging
    ];
}