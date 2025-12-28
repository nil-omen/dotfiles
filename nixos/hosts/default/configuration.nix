{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

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

  # Desktop Environment (GNOME & X11)
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
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

  system.stateVersion = "25.11";
}
