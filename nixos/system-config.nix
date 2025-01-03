{
  #
  # System Type & Profile
  #
  systemType = "desktop";
  hostName = "Gaming";
  bootloader = "systemd-boot";
 
  #
  # Profile Modules
  #
  packageModules = {
    gaming = {
      streaming = true;
      emulation = true;
    };
    development = {
      game = true;
      web = true;
    };
    server = {
      docker = false;
      web = false;
    };
  };

  #
  # User Management
  # 
  users = {
    "test" = {
      role = "admin";
      defaultShell = "zsh";
      autoLogin = false;
    };
    "test2" = {
      role = "admin";
      defaultShell = "zsh";
      autoLogin = false;
    };
  };

  #
  # Desktop Environment
  #
  desktop = {
    enable = true;
    environment = "plasma";
    display = {
      manager = "sddm";
      server = "wayland";
      session = "plasma";
    };
    theme = {
      dark = true;
    };
  };

  #
  # Hardware Configuration
  #
  hardware = {
    cpu = "intel";
    gpu = "amd";
    audio = "pipewire";
    # Weitere Hardware-Konfigurationen
  };

  #
  # Nix Configuration
  #
  allowUnfree = true;
  buildLogLevel = "minimal";

  #
  # Custom Features
  #
  entryManagement = true;
  preflightChecks = true;
  postflightChecks = true;
  sshManager = true;
  flakeUpdater = true;

  #
  # Security Settings
  #
  sudo = {
    requirePassword = false;
    timeout = 15;
  };
  enableFirewall = false;

  #
  # Localization
  #
  timeZone = "Europe/Berlin";
  locales = [ "en_US.UTF-8" ];
  keyboardLayout = "de";
  keyboardOptions = "eurosign";

  #
  # Profile Overrides
  #
  overrides = {
    enableSSH = null;
    enableSteam = true;
  };

  #
  # Hosting Configuration
  #
  email = "example@example.com";
  domain = "example.com";
  certEmail = "example@example.com";
}