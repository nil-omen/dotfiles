{ pkgs, lib, ... }:

let
  # Helper to create the tuple dconf expects: ('xkb', 'us')
  importFrom =
    type: value:
    lib.gvariant.mkTuple [
      type
      value
    ];
in
{
  # --- Default Applications (Edge & Zed) ---
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "microsoft-edge.desktop";
      "x-scheme-handler/http" = "microsoft-edge.desktop";
      "x-scheme-handler/https" = "microsoft-edge.desktop";
      "x-scheme-handler/about" = "microsoft-edge.desktop";
      "x-scheme-handler/unknown" = "microsoft-edge.desktop";
      "text/plain" = "zed.desktop";
      "application/json" = "zed.desktop";
    };
  };

  # --- GNOME Settings ---
  dconf.settings = {

    # 1. Interface & Input Sources
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      show-battery-percentage = true;
    };

    "org/gnome/desktop/input-sources" = {
      # Arabic (Egypt) and US English
      sources = [
        (importFrom "xkb" "us")
        (importFrom "xkb" "ara")
      ];
      xkb-options = [ "grp:win_space_toggle" ]; # Super+Space to switch
    };

    # 2. Window Manager Keybindings
    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" ];
      maximize = [ "<Super>Up" ];

      # Workspace Switching
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];

      # Move Window to Workspace
      move-to-workspace-1 = [ "<Shift><Super>1" ];
      move-to-workspace-2 = [ "<Shift><Super>2" ];
      move-to-workspace-3 = [ "<Shift><Super>3" ];
      move-to-workspace-4 = [ "<Shift><Super>4" ];

      # # Application Switcher
      # switch-applications = [ "<Super>Tab" ];
      # switch-windows = [ "<Alt>Tab" ];
    };

    # 3. Media Keys & Custom Shortcuts
    "org/gnome/settings-daemon/plugins/media-keys" = {
      home = [ "<Super>e" ];
      www = [ "<Super>b" ];
      help = [ ];
      calculator = [ ];
      email = [ ];

      # Register the two custom shortcuts
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
      ];
    };

    # Custom 0: Alacritty
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Alacritty";
      command = "alacritty";
      binding = "<Super>Return";
    };

    # Custom 1: Zed
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      name = "Zed";
      command = "zeditor"; # Ensure command matches the binary name
      binding = "<Super>z";
    };
  };

  # --- Enable Extensions Automatically ---
  # This setting ensures they are actually turned ON, not just installed.
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "blur-my-shell@aunetx"
        "clipboard-indicator@tudmotu.com"
      ];
    };
  };

  # --- Enable Pointer Cursor ---
  # Changed Cursor to Bibata-Modern-Ice
  home.pointerCursor = {
    enable = true;
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;

    # Ensures the cursor works in both X11 and Wayland (GNOME) apps
    gtk.enable = true;
    x11.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config.common.default = "*";
  };

}
