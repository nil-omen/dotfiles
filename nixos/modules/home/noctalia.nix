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
        widgets = {
          left = [
            {
              id = "ControlCenter";
              useDistroLogo = true;
            }
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

      colorSchemes.predefinedScheme = "Monochrome"; # User can change this later

      general = {
        radiusRatio = 0.2;
      };
    };
  };
}
