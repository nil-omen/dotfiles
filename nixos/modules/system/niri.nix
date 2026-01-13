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
  services.xserver.displayManager.gdm.enable = true;
}
