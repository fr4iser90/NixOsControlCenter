{
  #
  # Core System Configuration (Required)
  #
  system = {
    type = "desktop";      # desktop, server, hybrid, homelab
    name = "Gaming";       # Hostname
    boot = {
      loader = "systemd-boot";
      # Weitere Boot-Optionen wenn nötig
    };
  };

  #
  # Hardware Configuration (Kann teilweise automatisch ermittelt werden)
  #
  hardware = {
    cpu = "intel";
    gpu = "amd";
    audio = "pipewire";
    # Weitere Hardware-Konfigurationen
  };

  #
  # Desktop Environment (Optional, nur wenn system.type == "desktop")
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
      # Weitere Theme-Optionen
    };
  };

  #
  # User Management (Required)
  #
  users = {
    "test" = {
      role = "admin";
      shell = "zsh";
      autoLogin = false;
      # Weitere Benutzeroptionen
    };
  };

  #
  # Profile Configuration (Optional)
  #
  profiles = {
    gaming = {
      enable = true;
      features = {
        streaming = true;
        emulation = true;
      };
    };
    development = {
      enable = true;
      features = {
        game = true;
        web = true;
      };
    };
    server = {
      enable = false;
      features = {
        docker = false;
        web = false;
      };
    };
  };

  #
  # Security Configuration (Mit sinnvollen Defaults)
  #
  security = {
    sudo = {
      requirePassword = false;
      timeout = 15;
    };
    firewall.enable = false;
  };

  #
  # System Features (Optional mit Defaults)
  #
  features = {
    entry.management = true;
    checks = {
      preflight = true;
      postflight = true;
    };
    ssh.enable = true;
    updates = {
      auto = false;
      flakeUpdater = true;
    };
  };

  #
  # Localization (Kann teilweise automatisch ermittelt werden)
  #
  locale = {
    time.zone = "Europe/Berlin";
    language = [ "en_US.UTF-8" ];
    keyboard = {
      layout = "de";
      options = "eurosign";
    };
  };

  #
  # Nix Configuration (Mit sinnvollen Defaults)
  #
  nix = {
    allowUnfree = true;
    buildLogLevel = "minimal";
    # Weitere Nix-spezifische Optionen
  };

  #
  # Hosting Configuration (Optional)
  #
  hosting = {
    email = "example@example.com";
    domain = "example.com";
    certEmail = "example@example.com";
  };
}