{
  setup = "custom";
  mainUser = "fr4iser";
  guestUser = "";
  hostName = "Gaming";
  desktop = "plasma";
  displayManager = "sddm";
  session = "plasmawayland";
  autoLogin = true;
  timeZone = "Europe/Berlin";
  locales = [ "en_US.UTF-8" ];
  keyboardLayout = "de";
  keyboardOptions = "eurosign:e";
  darkMode = true;
  enableSSH = true;
  enableRemoteDesktop = false;
  enableSteam = true;
  enableVirtualization = false;
  enableFirewall = false;
  enablePrinting = false;
  enableBluetooth = false;
  enableBackup = false;
  securityHardening = false;
  defaultShell = "zsh";
  enableBash = true; 
  enableZsh = true;  
  enableFish = true;  
  enableTcsh = false;  
  enableDash = false;  
  enableKsh = false;  
  enableMksh = false;  
  enableXonsh = false;  
  defaultBrowser = "firefox";
  audio = "pipewire";
  gpu = "amdgpu";
  inputDevices = "libinput";
  networkManager = "networkmanager";
  backupDestination = "/mnt/backup";
  certEmail = "certemail";
  domain = "domain";
  email = "email";
  webHosting = "false";
}
