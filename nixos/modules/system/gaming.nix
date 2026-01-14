{ pkgs, ... }:

{
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
