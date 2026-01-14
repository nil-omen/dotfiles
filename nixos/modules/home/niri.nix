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

  home.sessionVariables = {
    # Fix for Electron apps (Heroic, Zed's webview parts) avoiding flickering or black screens
    NIXOS_OZONE_WL = "1";
    # Ensure Go tools are found if they aren't somehow picked up by shell integration
    # PATH is usually handled automatically, but we can force some things if needed.
  };

  # --- Default Applications (MimeTypes) ---
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Text
      "text/plain" = "dev.zed.Zed.desktop";
      "application/json" = "dev.zed.Zed.desktop";
      # Documents
      "application/pdf" = "org.gnome.Papers.desktop";
      # Directories
      "inode/directory" = "org.gnome.Nautilus.desktop";
      # Web
      "text/html" = "microsoft-edge.desktop";
      "x-scheme-handler/http" = "microsoft-edge.desktop";
      "x-scheme-handler/https" = "microsoft-edge.desktop";
      "x-scheme-handler/about" = "microsoft-edge.desktop";
      "x-scheme-handler/unknown" = "microsoft-edge.desktop";
    };
  };

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

      # Prefer Server-Side Decorations (SSD) - Disabled as it caused artifacts
      prefer-no-csd = false;

      # Layout
      layout = {
        gaps = 14;
        center-focused-column = "never";
        preset-column-widths = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];
        default-column-width = {
          proportion = 0.5;
        };

        # Disable decorations that break transparency
        focus-ring.enable = false;
        border.enable = false;
        shadow.enable = false;
      };

      # Window Rules
      window-rules = [
        {
          matches = [ { app-id = "^noctalia-shell$"; } ];
          open-floating = true;
        }
        {
          # Active Alacritty: Transparent
          matches = [
            {
              app-id = "^Alacritty$";
              is-focused = true;
            }
          ];
          opacity = 0.9;
        }
        {
          # Inactive Alacritty: Dimmed / More Transparent
          matches = [
            {
              app-id = "^Alacritty$";
              is-focused = false;
            }
          ];
          opacity = 0.6;
        }
        {
          # Zed Editor
          matches = [ { app-id = "^dev\.zed\.Zed$"; } ];
          opacity = 0.9;
        }
      ];

      # Spawn Noctalia on Startup
      spawn-at-startup = [
        { command = [ "noctalia-shell" ]; }
        { command = [ "xwayland-satellite" ]; } # XWayland support if needed, usually automatic on NixOS module

        # Overview background
        # {
        #   command = [
        #     "${pkgs.swaybg}/bin/swaybg"
        #     "-m"
        #     "fill"
        #     "-i"
        #     "/home/king/Pika-Wallpapers/Wallpaper_PikaOS_Parrot_8K.png"
        #   ];
        # }
      ];

      # Keybindings matching Gnome preferences
      binds = with config.lib.niri.actions; {
        # --- App Shortcuts ---
        "Mod+Return" = {
          action.spawn = [ "alacritty" ];
          hotkey-overlay.title = "Open Terminal (Alacritty)";
        };
        "Mod+Z" = {
          action.spawn = [ "zeditor" ];
          hotkey-overlay.title = "Open Editor (Zed)";
        };
        "Mod+B" = {
          action.spawn = [ "microsoft-edge" ];
          hotkey-overlay.title = "Open Browser (Edge)";
        };
        "Mod+E" = {
          action.spawn = [ "nautilus" ];
          hotkey-overlay.title = "Open File Manager (Nautilus)";
        };
        "Mod+O".action.toggle-overview = [ ];

        # --- System ---
        "Mod+Q".action.close-window = [ ];
        "Mod+Shift+E".action.quit = [ ];
        "Mod+L" = {
          action.spawn = noctalia "lockScreen lock";
          hotkey-overlay.title = "Lock Screen";
        };
        "Mod+Shift+P".action.power-off-monitors = [ ];

        # --- Screenshots ---
        "Print".action.screenshot = [ ];
        "Ctrl+Print".action.screenshot-screen = [ ];
        "Alt+Print".action.screenshot-window = [ ];

        # --- Common Niri Navigation ---
        "Mod+Left".action.focus-column-left = [ ];
        "Mod+Right".action.focus-column-right = [ ];
        "Mod+Up".action.focus-window-up = [ ];
        "Mod+Down".action.focus-window-down = [ ];

        # "Mod+H".action.focus-column-left = [ ];
        # "Mod+J".action.focus-window-down = [ ];
        # "Mod+K".action.focus-window-up = [ ];
        # "Mod+L".action.focus-column-right = [ ];

        "Mod+Home".action.focus-column-first = [ ];
        "Mod+End".action.focus-column-last = [ ];

        # --- Window/Column Movement ---
        "Mod+Shift+Left".action.move-column-left = [ ];
        "Mod+Shift+Right".action.move-column-right = [ ];

        "Mod+Ctrl+Left".action.move-column-left = [ ];
        "Mod+Ctrl+Down".action.move-window-down = [ ];
        "Mod+Ctrl+Up".action.move-window-up = [ ];
        "Mod+Ctrl+Right".action.move-column-right = [ ];

        # "Mod+Ctrl+H".action.move-column-left = [ ];
        # "Mod+Ctrl+J".action.move-window-down = [ ];
        # "Mod+Ctrl+K".action.move-window-up = [ ];
        # "Mod+Ctrl+L".action.move-column-right = [ ];

        "Mod+Ctrl+Home".action.move-column-to-first = [ ];
        "Mod+Ctrl+End".action.move-column-to-last = [ ];

        # --- Monitor Focus ---
        # "Mod+Shift+H".action.focus-monitor-left = [ ];
        # "Mod+Shift+J".action.focus-monitor-down = [ ];
        # "Mod+Shift+K".action.focus-monitor-up = [ ];
        # "Mod+Shift+L".action.focus-monitor-right = [ ];

        # # --- Move Column to Monitor ---
        # "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [ ];
        # "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [ ];
        # "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [ ];
        # "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [ ];

        # --- Workspace Navigation ---
        "Mod+Page_Down".action.focus-workspace-down = [ ];
        "Mod+Page_Up".action.focus-workspace-up = [ ];
        "Mod+U".action.focus-workspace-down = [ ];
        "Mod+I".action.focus-workspace-up = [ ];

        "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [ ];
        "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = [ ];
        "Mod+Ctrl+U".action.move-column-to-workspace-down = [ ];
        "Mod+Ctrl+I".action.move-column-to-workspace-up = [ ];

        "Mod+Shift+Page_Down".action.move-workspace-down = [ ];
        "Mod+Shift+Page_Up".action.move-workspace-up = [ ];
        "Mod+Shift+U".action.move-workspace-down = [ ];
        "Mod+Shift+I".action.move-workspace-up = [ ];

        # --- Workspace Index ---
        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;
        "Mod+6".action.focus-workspace = 6;
        "Mod+7".action.focus-workspace = 7;
        "Mod+8".action.focus-workspace = 8;
        "Mod+9".action.focus-workspace = 9;

        "Mod+Ctrl+1".action.move-column-to-workspace = 1;
        "Mod+Ctrl+2".action.move-column-to-workspace = 2;
        "Mod+Ctrl+3".action.move-column-to-workspace = 3;
        "Mod+Ctrl+4".action.move-column-to-workspace = 4;
        "Mod+Ctrl+5".action.move-column-to-workspace = 5;
        "Mod+Ctrl+6".action.move-column-to-workspace = 6;
        "Mod+Ctrl+7".action.move-column-to-workspace = 7;
        "Mod+Ctrl+8".action.move-column-to-workspace = 8;
        "Mod+Ctrl+9".action.move-column-to-workspace = 9;

        # --- Window/Column Manipulation ---
        "Mod+Comma".action.consume-window-into-column = [ ];
        "Mod+Period".action.expel-window-from-column = [ ];
        "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
        "Mod+BracketRight".action.consume-or-expel-window-right = [ ];

        "Mod+R".action.switch-preset-column-width = [ ];
        "Mod+Shift+R".action.switch-preset-window-height = [ ];
        "Mod+Ctrl+R".action.reset-window-height = [ ];

        "Mod+F".action.maximize-column = [ ];
        "Mod+Shift+F".action.fullscreen-window = [ ];
        "Mod+M".action.maximize-window-to-edges = [ ];
        "Mod+C".action.center-column = [ ];
        "Mod+Ctrl+C".action.center-visible-columns = [ ];

        "Mod+Minus".action.set-column-width = "-10%";
        "Mod+Equal".action.set-column-width = "+10%";
        "Mod+Shift+Minus".action.set-window-height = "-10%";
        "Mod+Shift+Equal".action.set-window-height = "+10%";

        "Mod+V".action.toggle-window-floating = [ ];
        "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [ ];
        "Mod+W".action.toggle-column-tabbed-display = [ ];

        # --- Noctalia Integration ---
        "Mod+D" = {
          action.spawn = noctalia "launcher toggle";
          hotkey-overlay.title = "Open Launcher";
        };
        "Mod+Ctrl+V" = {
          action.spawn = noctalia "launcher clipboard";
          hotkey-overlay.title = "Open Clipboard";
        };
        "Mod+Shift+Period" = {
          action.spawn = noctalia "launcher emoji";
          hotkey-overlay.title = "Open Emoji";
        };
        "Mod+P" = {
          action.spawn = noctalia "sessionMenu toggle";
          hotkey-overlay.title = "Open Session Menu";
        };
        "Mod+S" = {
          action.spawn = noctalia "controlCenter toggle";
          hotkey-overlay.title = "Open Control Center";
        };
        "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];

        # --- Audio ---
        "XF86AudioRaiseVolume".action.spawn = noctalia "volume increase";
        "XF86AudioLowerVolume".action.spawn = noctalia "volume decrease";
        "XF86AudioMute".action.spawn = noctalia "volume muteOutput";
        "XF86AudioMicMute".action.spawn = noctalia "volume muteInput";

        # --- Media Control ---
        "XF86AudioPlay".action.spawn = [
          "playerctl"
          "play-pause"
        ];
        "XF86AudioPause".action.spawn = [
          "playerctl"
          "pause"
        ];
        "XF86AudioNext".action.spawn = [
          "playerctl"
          "next"
        ];
        "XF86AudioPrev".action.spawn = [
          "playerctl"
          "previous"
        ];
        "XF86AudioStop".action.spawn = [
          "playerctl"
          "stop"
        ];

        "XF86MonBrightnessUp".action.spawn = [
          "brightnessctl"
          "set"
          "10%+"
        ];
        "XF86MonBrightnessDown".action.spawn = [
          "brightnessctl"
          "set"
          "10%-"
        ];

        # --- Mouse Wheel ---
        "Mod+WheelScrollDown".action.focus-workspace-down = [ ];
        "Mod+WheelScrollUp".action.focus-workspace-up = [ ];
        "Mod+Ctrl+WheelScrollDown".action.move-column-to-workspace-down = [ ];
        "Mod+Ctrl+WheelScrollUp".action.move-column-to-workspace-up = [ ];

        "Mod+WheelScrollRight".action.focus-column-right = [ ];
        "Mod+WheelScrollLeft".action.focus-column-left = [ ];
        "Mod+Ctrl+WheelScrollRight".action.move-column-right = [ ];
        "Mod+Ctrl+WheelScrollLeft".action.move-column-left = [ ];

        "Mod+Shift+WheelScrollDown".action.focus-column-right = [ ];
        "Mod+Shift+WheelScrollUp".action.focus-column-left = [ ];
        "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = [ ];
        "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = [ ];
      };
    };
  };
}
