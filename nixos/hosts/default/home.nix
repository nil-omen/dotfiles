{ config, pkgs, ... }:

let
  # Define the path to your dotfiles repo
  dotfilesDir = "${config.home.homeDirectory}/dotfiles";
in
{
  home.username = "king";
  home.homeDirectory = "/home/king";

  # Link apps to system menu
  targets.genericLinux.enable = true;

  home.packages = with pkgs; [
    # -- Editors --
    helix
    zed-editor
    vim # Added per request

    # -- Nix support --
    nil
    nixfmt-rfc-style

    # -- Terminal Tools --
    alacritty
    kitty # Added per request
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
    gnome-tweaks
    wl-clipboard
    localsend
    bruno

    # -- Go Development --
    go
    gopls
    delve
    gotools
  ];

  # --- 1. Git Setup ---
  # We just enable the package here.
  # The config is handled by the "home.file" block below to use your .gitconfig
  programs.git.enable = true;

  # --- 2. Shell & Prompt ---
  programs.starship = {
    enable = true;
    settings = pkgs.lib.importTOML "${dotfilesDir}/starship/.config/starship.toml";
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      source ${dotfilesDir}/fish/.config/fish/config.fish
    '';
  };

  # --- 3. Linking Dotfiles (The "Whole Folder" Strategy) ---

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

  # > .config/fish/functions (Whole folder)
  xdg.configFile."fish/functions".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/fish/.config/fish/functions";

  # > .config/fish/conf.d (Individual files to avoid breaking Home Manager)
  xdg.configFile."fish/conf.d/done.fish".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/fish/.config/fish/conf.d/done.fish";

  # --- 4. Home Directory Files ---

  # > .gitconfig (Uses the one at ~/dotfiles/git/.gitconfig)
  home.file.".gitconfig".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/git/.gitconfig";

  # > .vim folder (Includes your plugins/settings if inside .vim)
  home.file.".vim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/vim/.vim";

  # This version number rarely changes
  home.stateVersion = "25.11";
}
