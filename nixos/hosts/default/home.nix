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

  # Link apps to system menu
  targets.genericLinux.enable = true;

  home.packages = with pkgs; [
    # -- Editors --
    helix
    zed-editor
    # vim # Added per request

    # -- Nix support --
    nixd
    nixfmt-rfc-style

    # -- Terminal Tools --
    alacritty
    # kitty # Added per request
    zoxide
    eza
    fzf
    bat
    ripgrep
    fd

    # -- Version Control --
    gh
    lazygit
    # stow # No longer needed!

    # -- Browser --
    microsoft-edge

    # -- Utilities --
    wl-clipboard
    localsend
    bruno

    # -- Go Development --
    go
    gopls
    delve
    gotools

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

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting ""       # Disable greeting
      source ${dotfilesDir}/fish/.config/fish/config.fish
    '';
  };

  # --- 3. Linking Dotfiles (The "Whole Folder" Strategy) ---

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

  # > .config/alacritty (Includes all themes and alacritty.toml)
  xdg.configFile."alacritty".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/alacritty/.config/alacritty";

  # > .config/helix (Includes config.toml and languages.toml)
  xdg.configFile."helix".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/helix/.config/helix";

  # > .config/zed (Includes settings, keymap, AND tasks.json)
  xdg.configFile."zed".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/zed/.config/zed";

  # > .config/kitty (Just in case)
  xdg.configFile."kitty".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/kitty/.config/kitty";

  # --- 4. Home Directory Files ---

  # > .gitconfig (Uses the one at ~/dotfiles/git/.gitconfig)
  home.file.".gitconfig".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/git/.gitconfig";

  # > .vim folder (Includes your plugins/settings if inside .vim)
  home.file.".vim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/vim/.vim";

  # This version number rarely changes
  home.stateVersion = "25.11";
}
