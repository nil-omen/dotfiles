{
  config,
  pkgs,
  pkgs-stable,
  ...
}:

let
  # Define the path to your dotfiles repo
  dotfilesDir = "${config.home.homeDirectory}/dotfiles";
in
{

  imports = [
    ../../modules/home/gnome.nix
  ];

  home.username = "king";
  home.homeDirectory = "/home/king";

  # # Link apps to system menu
  # targets.genericLinux.enable = true;

  # --- Global Cursor Configuration ---
  home.pointerCursor = {
    enable = true;
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;

    # These ensure the cursor is set for X11 (old apps) and GTK apps
    gtk.enable = true;
    x11.enable = true;

  };

  # (Optional) Some Wayland compositors (like Hyprland) need this variable set
  home.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
  };

  # --- Global GTK Theme (Icons & Fonts) ---
  gtk = {
    enable = true;

    # 1. Install Papirus Icon Theme
    iconTheme = {
      name = "Papirus-Dark"; # Options: "Papirus", "Papirus-Light", "Papirus-Dark"
      package = pkgs.papirus-icon-theme;
    };

    # 2. (Optional) Force the Theme in GTK apps
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    # 3. [NEW] FONT CONFIGURATION
    # To change the font, uncomment the lines below and change the name/package.
    # font = {
    #   name = "Inter 11";
    #   package = pkgs.inter;
    # };
  };

  # --- Global Direnv Configuration ---
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true; # Essential for Flakes speed
  };

  home.packages = with pkgs; [
    # -- Editors --
    helix
    zed-editor
    antigravity

    # -- Nix support --
    nixd
    nixfmt-rfc-style

    # -- Terminal Tools --
    alacritty
    zoxide
    eza
    fzf
    bat
    ripgrep
    fd

    # -- Version Control --
    gh
    lazygit
    jujutsu # Git-like version control system

    # -- Browser --
    microsoft-edge

    # -- Utilities --
    wl-clipboard
    localsend # File Sharing
    bruno # API Testing
    foliate # eBook Reader
    haruna # Video Player

    # -- Go Development --
    go
    gopls
    delve
    gotools
    gcc

    # -- Using Stable Packages --
    # By default, packages come from nixos-unstable (latest)
    # To use a stable package instead, use pkgs-stable:
    #
    # Example: Use stable Firefox instead of unstable
    # (pkgs-stable.firefox)
    #
    # Example: Use stable Rust instead of unstable
    # (pkgs-stable.rustup)
    #
    # Stable packages are tested and more reliable, but less frequently updated
  ];

  # --- 1. Git Setup ---
  # We just enable the package here.
  # The config is handled by the "home.file" block below to use your .gitconfig
  programs.git.enable = true;

  # --- 2. Shell & Prompt ---
  programs.starship = {
    enable = true;
  };
  xdg.configFile."starship.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/starship/.config/starship.toml";
  xdg.configFile."starship-nix.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/starship/.config/starship-nix.toml";

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting ""       # Disable greeting
      source ${dotfilesDir}/fish/.config/fish/config.fish
    '';
  };

  # --- 3. Linking Dotfiles (The "Whole Folder" Strategy) ---

  # --- Fish ---
  # > .config/fish/functions (Whole folder)
  xdg.configFile."fish/functions".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/fish/.config/fish/functions";

  # > .config/fish/conf.d (Individual files to avoid breaking Home Manager)
  xdg.configFile."fish/conf.d/done.fish".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/fish/.config/fish/conf.d/done.fish";

  # 3. Fish Variables (CRITICAL: Restores abbreviations and universal vars)
  # This allows fish to read/write variables directly to your dotfiles repo
  xdg.configFile."fish/fish_variables".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/fish/.config/fish/fish_variables";

  # 4. Extra Configs (If your config.fish sources this, it needs to exist!)
  xdg.configFile."fish/cachyos-config.fish".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/fish/.config/fish/cachyos-config.fish";

  # --- Apps ---

  # > .config/alacritty (Includes all themes and alacritty.toml)
  xdg.configFile."alacritty".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/alacritty/.config/alacritty";

  # > .config/helix (Includes config.toml and languages.toml)
  xdg.configFile."helix".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/helix/.config/helix";

  # > .config/zed (Includes settings, keymap, AND tasks.json)
  xdg.configFile."zed".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/zed/.config/zed";

  # > .config/kitty
  xdg.configFile."kitty".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/kitty/.config/kitty";

  # > .config/jj (Includes config.toml)
  xdg.configFile."jj".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/jj/.config/jj";

  # --- 4. Home Directory Files ---

  # > .gitconfig (Uses the one at ~/dotfiles/git/.gitconfig)
  home.file.".gitconfig".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/git/.gitconfig";

  # > .vim folder (Includes your plugins/settings if inside .vim)
  home.file.".vim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/vim/.vim";

  # This version number rarely changes
  home.stateVersion = "25.11";
}
