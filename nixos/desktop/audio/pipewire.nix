# /etc/nixos/modules/sound/pipewire.nix

{ config, pkgs, ... }:

{
  # Stelle sicher, dass PulseAudio deaktiviert ist, weil wir PipeWire verwenden
#  services.pulseaudio.enable = false;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
#    alsa.enable = true;
#    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  environment.systemPackages = with pkgs; [
#    pipewire
    pavucontrol  # PulseAudio Volume Control
    alsa-utils   # ALSA Utilities
    qpwgraph     # Graphisches Frontend für PipeWire
    mda_lv2      # LADSPA-Plugins
    calf         # Weitere Audio-Plugins
  ];
}