{ pkgs, pkgs-unstable, ... }:

{
  programs.niri = {
    enable = true;
    package = pkgs-unstable.niri;
  };

  # xdg-desktop-portal-niri is automatically installed with programs.niri.enable
  # But we ensure it's integrated
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    config.niri.default = [
      "gtk"
      "gnome"
    ];
  };

  # Essential services for Noctalia components (Battery, Wifi, etc.)
  # Most are already standard but ensuring them here
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # GDM integration is automatic when niri is enabled system-wide, it searches /share/wayland-sessions
  services.displayManager.gdm.enable = true;

  # Essential Gnome Utilities that user wants to keep
  environment.systemPackages = with pkgs; [
    nautilus # File Manager
    papers # Document Viewer
    gnome-disk-utility # Disk Management
    baobab # Disk Usage Analyzer
    file-roller # Archive Manager
    gnome-text-editor # Simple Text Editor (Optional, user likes for small changes)
    loupe # Image Viewer (modern replacement for Eye of Gnome)
    brightnessctl # Brightness control
    gnome-font-viewer # Font Viewer
    gnome-system-monitor # System Monitor

    # Core system tools
    libsecret # Secret management (important for auth)
    polkit_gnome # Polkit agent
    seahorse # Keyring manager
    playerctl # Media control utility
  ];

  # Use Gnome keyring for secrets
  services.gnome.gnome-keyring.enable = true;

  # Ensure Nautilus extensions work (optional but good)
  programs.nautilus-open-any-terminal.enable = true;
}
