#!/bin/bash
# Install Zsh Configuration
# Use bash for the installer to be portable before Zsh is set up.

set -e

DOTFILES_DIR="$HOME/dotfiles"
ZSH_PACKAGE_DIR="$DOTFILES_DIR/zsh"
# Target config structure: ~/dotfiles/zsh/.config/zsh
CONFIG_DIR="$ZSH_PACKAGE_DIR/.config/zsh"
PLUGIN_DIR="$CONFIG_DIR/plugins"
FUNCTIONS_DIR="$CONFIG_DIR/functions"

# Parse arguments
PLUGINS_ONLY=false

for arg in "$@"; do
    case $arg in
        --plugins-only)
            PLUGINS_ONLY=true
            shift
            ;;
        *)
            ;;
    esac
done

echo ">> Starting Zsh Setup..."

# 0. Restructure (Quick migration if old structure exists)
# We run this even in plugins-only mode to ensure the directory structure exists for plugins
if [[ -f "$ZSH_PACKAGE_DIR/.zshrc" ]]; then
    echo ">> Migrating to clean structure (moving files to .config/zsh)..."
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$PLUGIN_DIR"
    mkdir -p "$FUNCTIONS_DIR"
    
    # Move files if they verify as files
    [[ -f "$ZSH_PACKAGE_DIR/.zshrc" ]] && mv "$ZSH_PACKAGE_DIR/.zshrc" "$CONFIG_DIR/"
    [[ -f "$ZSH_PACKAGE_DIR/aliases.zsh" ]] && mv "$ZSH_PACKAGE_DIR/aliases.zsh" "$CONFIG_DIR/"
    
    # Move dirs
    if [[ -d "$ZSH_PACKAGE_DIR/functions" ]]; then
        # Copy content to new functions dir
        cp -r "$ZSH_PACKAGE_DIR/functions/"* "$FUNCTIONS_DIR/" 2>/dev/null || true
        rm -rf "$ZSH_PACKAGE_DIR/functions"
    fi
     if [[ -d "$ZSH_PACKAGE_DIR/plugins" ]]; then
        # Copy content to new plugins dir
        cp -r "$ZSH_PACKAGE_DIR/plugins/"* "$PLUGIN_DIR/" 2>/dev/null || true
        rm -rf "$ZSH_PACKAGE_DIR/plugins"
    fi
fi

# Ensure dirs exist
mkdir -p "$PLUGIN_DIR"
mkdir -p "$FUNCTIONS_DIR"

if [[ "$PLUGINS_ONLY" == "false" ]]; then
    # 1. Install Dependencies
    echo ">> Checking Dependencies..."

    install_pkg() {
        local pkg_name="$1"
        # Detect package manager - Prioritize Native (DNF/Apt) over Nix
        if command -v dnf &> /dev/null; then
            if ! rpm -q "$pkg_name" &> /dev/null; then
                 echo "Installing $pkg_name via DNF..."
                 sudo dnf install -y "$pkg_name" || echo "Warning: Failed to install $pkg_name"
            fi
        elif command -v apt &> /dev/null; then
            if ! dpkg -l | grep -q "$pkg_name"; then
                 echo "Installing $pkg_name via Apt..."
                 sudo apt update && sudo apt install -y "$pkg_name" || echo "Warning: Failed to install $pkg_name"
            fi
        elif command -v nix-env &> /dev/null; then
             if ! command -v "$pkg_name" &> /dev/null; then
                echo "Installing $pkg_name via Nix..."
                nix-env -iA "nixos.$pkg_name" || echo "Warning: Failed to install $pkg_name with Nix"
             fi
        else
            echo "Warning: No supported package manager found. Please manually install $pkg_name."
        fi
    }

    install_pkg zsh
    install_pkg stow
    install_pkg fzf
    install_pkg zoxide
    install_pkg bat
    install_pkg ripgrep
    install_pkg fd-find 
    
    # Try eza, fallback to exa, or just warn (handle dnf failure gracefully)
    if command -v dnf &> /dev/null; then
         # Fedora sometimes has eza, sometimes not, or it might be named differently
         install_pkg eza || echo "Trying exa..." && install_pkg exa || echo "Warning: Could not install eza/exa."
    else
         install_pkg eza
    fi

    # Notifications (for zsh-auto-notify)
    if command -v apt &> /dev/null; then
        install_pkg libnotify-bin
        install_pkg notification-daemon
    elif command -v dnf &> /dev/null; then
        install_pkg libnotify
        install_pkg notification-daemon || true # notification-daemon might be named differently or not strictly needed if another daemon is running
    elif command -v nix-env &> /dev/null; then
        install_pkg libnotify
    fi 
fi

# 2. Setup Plugins
echo ">> Setting up Plugins..."

clone_plugin() {
    local name="$1"
    local repo="$2"
    if [[ ! -d "$PLUGIN_DIR/$name" ]]; then
        echo "Cloning $name..."
        git clone --depth 1 "$repo" "$PLUGIN_DIR/$name"
    else
        echo "Updating $name..."
        git -C "$PLUGIN_DIR/$name" pull --rebase --autostash
    fi
}

clone_plugin "zsh-fast-syntax-highlighting" "https://github.com/zdharma-continuum/fast-syntax-highlighting.git"
clone_plugin "zsh-autocomplete" "https://github.com/marlonrichert/zsh-autocomplete.git"
clone_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions.git"
clone_plugin "zsh-history-substring-search" "https://github.com/zsh-users/zsh-history-substring-search.git"
clone_plugin "zsh-sudo" "https://github.com/hcgraf/zsh-sudo.git"
clone_plugin "zsh-auto-notify" "https://github.com/MichaelAquilina/zsh-auto-notify.git"


if [[ "$PLUGINS_ONLY" == "false" ]]; then
    # 3. Stow Dotfiles
    echo ">> Linking Dotfiles with Stow..."
    if command -v stow &> /dev/null; then
        cd "$DOTFILES_DIR"
        # Stow 'zsh' package
        stow -v -R zsh
    else
        echo "Error: stow is not available."
        exit 1
    fi
fi

echo ">> Setup Complete!"
if [[ "$PLUGINS_ONLY" == "true" ]]; then
    echo ">> Plugins updated. System dependencies and dotfile linking were skipped."
else
    echo ">> Please restart your shell or run 'zsh' to see changes."
fi
