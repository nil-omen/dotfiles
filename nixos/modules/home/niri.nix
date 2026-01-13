{
  pkgs,
  pkgs-unstable,
  config,
  inputs,
  ...
}:

let
  # Helper for Noctalia IPC commands
  noctalia =
    cmd:
    [
      "noctalia-shell"
      "ipc"
      "call"
    ]
    ++ (pkgs.lib.splitString " " cmd);
in
{
  imports = [
    inputs.niri.homeModules.niri
  ];

  programs.niri = {
    # Ensure usage of the same package as system
    package = pkgs-unstable.niri;

    settings = {
      # Basic Input Settings
      input = {
        keyboard.xkb = {
          layout = "us,ara";
          options = "grp:win_space_toggle";
        };
        touchpad = {
          tap = true;
          dwt = true;
        };
      };

      # Layout
      layout = {
        gaps = 16;
        center-focused-column = "always";
        preset-column-widths = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];
        default-column-width = {
          proportion = 0.5;
        };
      };

      # Window Rules
      window-rules = [
        {
          matches = [ { app-id = "^noctalia-shell$"; } ];
          open-floating = true;
        }
      ];

      # Spawn Noctalia on Startup
      spawn-at-startup = [
        { command = [ "noctalia-shell" ]; }
        { command = [ "xwayland-satellite" ]; } # XWayland support if needed, usually automatic on NixOS module
      ];

      # Keybindings matching Gnome preferences
      binds = with config.lib.niri.actions; {
        # --- App Shortcuts ---
        "Mod+Return".action.spawn = [ "alacritty" ];
        "Mod+Z".action.spawn = [ "zed" ]; # User specific
        "Mod+B".action.spawn = [ "microsoft-edge" ]; # User specific browser
        "Mod+E".action.spawn = [ "nautilus" ]; # Gnome File Manager

        # --- System ---
        "Mod+Q".action.close-window = [ ];
        "Mod+Shift+E".action.quit = [ ];
        "Mod+L".action.spawn = noctalia "lockScreen lock";

        # --- Common Niri Navigation ---
        "Mod+Left".action.focus-column-left = [ ];
        "Mod+Right".action.focus-column-right = [ ];
        "Mod+Shift+Left".action.move-column-left = [ ];
        "Mod+Shift+Right".action.move-column-right = [ ];

        "Mod+WheelScrollDown".action.focus-workspace-down = [ ];
        "Mod+WheelScrollUp".action.focus-workspace-up = [ ];
        "Mod+Ctrl+Left".action.focus-monitor-left = [ ];
        "Mod+Ctrl+Right".action.focus-monitor-right = [ ];

        # --- Noctalia Integration ---
        "Mod+Space".action.spawn = noctalia "launcher toggle";
        # "Mod+Space".action.spawn = noctalia "launcher open"; # Alternatively just open
        # "Mod+P".action.spawn = noctalia "sessionMenu toggle"; # Example

        # --- Audio ---
        "XF86AudioRaiseVolume".action.spawn = noctalia "volume increase";
        "XF86AudioLowerVolume".action.spawn = noctalia "volume decrease";
        "XF86AudioMute".action.spawn = noctalia "volume muteOutput";
      };
    };
  };
}
