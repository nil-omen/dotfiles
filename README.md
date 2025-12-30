# My Dotfiles

Welcome to my dotfiles repository! This repository contains personal configuration files and scripts for setting up a development environment on NixOS or traditional Linux distributions.

## Table of Contents

- [Introduction](#introduction)
- [NixOS Setup](#nixos-setup)
- [Traditional Linux Setup (GNU Stow)](#traditional-linux-setup-gnu-stow)
- [Scripts](#scripts)
- [Directory Structure](#directory-structure)

## Introduction

This repository provides configuration for:
- **NixOS**: Declarative system configuration using Nix Flakes
- **Traditional Linux** (CachyOS, Arch, Ubuntu, Debian, etc.): Configuration management via GNU Stow

Choose the setup method that matches your system.

## NixOS Setup

If you're using **NixOS**, see the comprehensive guide in [`nixos/README.md`](nixos/README.md).

**Quick start:**
```shell
git clone https://github.com/your-username/dotfiles.git ~/dotfiles
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#nixos
```

The `nixos/` directory contains:
- `flake.nix` - Flake configuration (entry point)
- `hosts/default/configuration.nix` - System-wide settings
- `hosts/default/home.nix` - User configuration (Home Manager)
- `hosts/default/hardware-configuration.nix` - Hardware settings

**For detailed instructions, troubleshooting, and advanced configurations, see [`nixos/README.md`](nixos/README.md).**

## Traditional Linux Setup (GNU Stow)

For **non-NixOS systems**, use [GNU Stow](https://www.gnu.org/software/stow/) to manage configuration files.

**Prerequisites:**
```shell
# Install GNU Stow
sudo pacman -S stow        # Arch/CachyOS
sudo apt-get install stow  # Debian/Ubuntu
```

**Installation:**

1. Clone the repository:
   ```shell
   git clone https://github.com/your-username/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Stow individual directories:
   ```shell
   stow alacritty fish git helix starship vim zed
   ```

   Or stow all at once:
   ```shell
   for dir in */; do stow "$dir"; done
   ```

3. **Backup existing configs first** to avoid conflicts.

**Available configurations:**
- **`alacritty/`** - Terminal emulator
- **`fish/`** - Fish shell configuration
- **`git/`** - Git global config
- **`helix/`** - Helix editor with language servers
- **`kitty/`** - Kitty terminal emulator
- **`starship/`** - Starship prompt
- **`vim/`** - Vim configuration
- **`zed/`** - Zed editor

## Scripts

This repository includes utility scripts for system setup.

### Install Tools (CachyOS)

Automates installation of development tools on CachyOS:

```shell
chmod +x scripts/install_tools-CachyOS.sh
./scripts/install_tools-CachyOS.sh
```

**Features:**
- Installs packages from official and AUR repositories
- Configures Docker (adds user to docker group)
- Installs Rust toolchain
- Sets up firewall rules for LocalSend

**Available options:**
```shell
./scripts/install_tools-CachyOS.sh --list              # List packages
./scripts/install_tools-CachyOS.sh --skip-confirmation # Skip prompt
```

See the script source for customization.

### Nerd Fonts Install

Automates Nerd Fonts installation with interactive selection:

```shell
chmod +x scripts/nerd-fonts-install.sh
./scripts/nerd-fonts-install.sh
```

**Features:**
- Downloads Nerd Fonts from GitHub
- Interactive font selection
- Local or global installation support
- Automatic font cache update

## Directory Structure

```
dotfiles/
├── alacritty/          # Alacritty terminal config
├── fish/               # Fish shell config
├── git/                # Git configuration
├── helix/              # Helix editor config
├── kitty/              # Kitty terminal config
├── nixos/              # NixOS configuration (see nixos/README.md)
├── scripts/            # Utility scripts
├── starship/           # Starship prompt config
├── vim/                # Vim configuration
├── zed/                # Zed editor config
└── README.md           # This file
```

## Editor Configurations

### Helix

[Helix](https://helix-editor.com/) is configured with language servers for Go, Rust, Python, YAML, Bash, and TOML.

**Installation (Traditional Linux):**
```shell
sudo pacman -S helix
stow helix
```

**Installation (NixOS):**
See `nixos/README.md` — Helix is included in the Home Manager configuration.

**Verify language servers:**
```shell
hx --health
```

## Contributing

Feel free to fork and customize for your own setup. Some tips:
- Backup your existing dotfiles before stowing
- On NixOS, never use stow — use the flake configuration instead
- Test configuration changes before committing to git

## License

These dotfiles are provided as-is for personal use.