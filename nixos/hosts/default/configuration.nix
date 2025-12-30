{
  config,
  pkgs,
  pkgs-stable,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/gnome.nix
    ../../modules/system/dell-precision-7520.nix
  ];

  # Latest Linux Kernel Packages
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 53317 ];
  networking.firewall.allowedUDPPorts = [ 53317 ];

  # Time and Locale
  time.timeZone = "Africa/Cairo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Printing
  services.printing.enable = true;

  # User Account
  users.users.king = {
    isNormalUser = true;
    description = "king";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.fish;
  };

  # Database (Kept here because it is a system service)
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureDatabases = [ "snippetbox" ];
    ensureUsers = [
      {
        name = "web";
        ensurePermissions = {
          "snippetbox.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  # System-wide Essentials
  nixpkgs.config.allowUnfree = true;
  programs.fish.enable = true; # Required for shell to work at login

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.meslo-lg
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # System Packages
  # By default, packages come from nixos-unstable (latest, frequent updates)
  # To use a stable package instead, use pkgs-stable:
  #
  # Example: Use stable PostgreSQL instead of unstable
  # (pkgs-stable.postgresql)
  #
  # Example: Use stable Nginx instead of unstable
  # (pkgs-stable.nginx)
  #
  # Stable packages are tested and more reliable, recommended for system services
  environment.systemPackages = with pkgs; [
    btop
  ];

  # Nix LD for dynamically linked binaries (e.g., Zed, VS Code, other generic Linux apps)
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    openssl
    glib
    libxcb
    zlib
    # Add more as needed for other apps:
    # libxkbcommon    # Keyboard handling
    # libwayland      # Wayland display protocol
    # xorg.libX11     # X11 core library
    # libGL           # OpenGL graphics
    # libudev         # Device management
  ];

  system.stateVersion = "25.11";
}
