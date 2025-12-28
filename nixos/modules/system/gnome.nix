{ pkgs, ... }:

{
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Remove default GNOME applications
  environment.gnome.excludePackages = (
    with pkgs;
    [
      # gnome-photos
      gnome-tour
      # gedit # Text Editor (You use Helix/Zed)
      cheese # Webcam
      # gnome-music
      # gnome-terminal # You use Alacritty
      epiphany # Web Browser
      geary # Email Client
      # evince # Document Viewer
      # gnome-characters
      # totem # Video Player
      tali # A poker-style dice game (similar to Yahtzee).
      iagno # A strategy board game (a clone of Reversi/Othello).
      hitori # A logic puzzle game similar to Sudoku.
      atomix # A puzzle game where you push atoms to build molecules.

      gnome-contacts
      gnome-weather
      gnome-maps
      gnome-calendar
    ]
  );

  # Further removal of specific apps you screenshotted
  # services.gnome.core-utilities.enable = false; # Disables a huge chunk of defaults

  # Re-add only the essentials you might actually need
  environment.systemPackages = with pkgs; [
    # --- Utilities ---
    gnome-tweaks # The tweak tool
    # evince # Document Viewer (PDFs)
    # gedit # Text Editor
    # gnome-console # Terminal
    # gnome-music
    # totem # Video Player
    # gnome-photos

    # --- Extensions ---
    # You must install the extension package for it to work
    gnomeExtensions.blur-my-shell
    gnomeExtensions.clipboard-indicator

    # nautilus # File Manager
    # gnome-disk-utility
    # seahorse # Keyring
    # sushi        # File previewer (optional)
  ];

  # Basic X11 Keymap (Fallback)
  services.xserver.xkb = {
    layout = "us,ara";
    variant = "";
    options = "grp:win_space_toggle";
  };
}
