{ pkgs, ... }:

{

  # --- CachyOS-like Performance Tweaks ---
  # 1. Enable the System76 Scheduler (improves game responsiveness/smoothness)
  services.system76-scheduler.settings.cfsProfiles.enable = true;

  # 2. Add 'mitigations=off' to kernel parameters?
  # Only uncomment the line below if you want maximum raw FPS (like CachyOS)
  # at the cost of slight security reduction.
  # boot.kernelParams = [ "mitigations=off" ];


  # Core gaming setup using Heroic Games Launcher

  # Enable OpenGL/Vulkan support (32-bit included)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Optimize system performance for gaming
  programs.gamemode.enable = true;

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  environment.systemPackages = with pkgs; [
    heroic
    protonup-qt
    ludusavi

    # Overlay Tools
    # mangohud
    # goverlay
    # vkbasalt

    # Future Proofing: Lutris (commented out)
    # lutris

    # REQUIRED tools for Winetricks/Proton to work:
    unzip
    cabextract
    p7zip
  ];

  # Future Proofing: Steam (commented out)
  # programs.steam = {
  #   enable = true;
  #   remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  #   dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  # };
}
