{ pkgs, inputs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;

    # Do not enable systemd service here if using niri spawn-at-startup as per docs
    # systemd.enable = false;

    settings = {
      bar = {
        density = "compact";
        position = "top";
        showCapsule = true; # Floating "island" look
        widgets = {
          left = [
            {
              id = "ControlCenter";
              useDistroLogo = true;
            }
            { id = "Launcher"; } # Explicit launcher button if supported, or just keep simple
            { id = "Workspace"; }
          ];
          center = [
            {
              id = "Clock";
              formatHorizontal = "HH:mm";
            }
          ];
          right = [
            { id = "WiFi"; }
            { id = "Bluetooth"; }
            {
              id = "Battery";
              warningThreshold = 20;
            }
          ];
        };
      };

      ui = {
        fontDefault = "Rubik";
        fontFixed = "MesloLGMDZ Nerd Font Mono";
      };
      location = {
        name = "Cairo";
        use12hourFormat = true;
      };

      appLauncher = {
        enableClipboardHistory = true;
      };

      colorSchemes = {
        useWallpaperColors = true;
        predefinedScheme = "Fruit Salad"; # User can change this later
        darkMode = true;
      };

      general = {
        radiusRatio = 0.2;
      };
    };
  };
}
