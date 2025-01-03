{ config, lib, pkgs, systemConfig, ... }:

{
  imports = [
    ./gpu
    ./cpu
  ];

  assertions = [
    {
      assertion = builtins.elem systemConfig.hardware.audio ["pulseaudio" "pipewire" "none"];
      message = "Invalid audio configuration: ${systemConfig.hardware.audio}";
    }
    # Weitere allgemeine Hardware-Assertions hier...
  ];
}