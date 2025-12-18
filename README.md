# My Dotfiles

Welcome to my dotfiles repository! This repository stores my personal configuration files (dotfiles) and scripts, designed to streamline the setup of a new system, particularly CachyOS.

## Table of Contents

- [Introduction](#introduction)
- [Installation with GNU Stow](#installation-with-gnu-stow)
- [Scripts](#scripts)
  - [Install Tools (CachyOS)](#install-tools-cachyos)
  - [Nerd Fonts Install](#nerd-fonts-install)
- [Directory Structure](#directory-structure)

## Introduction

This repository contains my personal configurations for various tools and applications, aimed at providing a consistent and efficient development environment across different machines. By using [GNU Stow](https://www.gnu.org/software/stow/), you can easily symlink these configuration files to your home directory without manually copying them.

## Installation with GNU Stow

[GNU Stow](https://www.gnu.org/software/stow/) is a symlink farm manager that helps manage symbolic links to configuration files.

1.  **Clone the repository:**
    ```shell
    git clone https://github.com/your-username/dotfiles.git ~/.dotfiles
    ```
    (Replace `your-username` with your actual GitHub username)

2.  **Navigate to the dotfiles directory:**
    ```shell
    cd ~/.dotfiles
    ```

3.  **Stow individual directories:**
    To install the dotfiles for a specific application, use `stow` with the directory name. For example, to install `fish` shell configurations:
    ```shell
    stow fish
    ```
    This will create symlinks from `~/.dotfiles/fish` to `~/.config/fish` and other relevant locations in your home directory.

    You can also stow multiple directories:
    ```shell
    stow alacritty fish git kitty starship vim zed
    ```
    **Note:** Make sure to back up your existing dotfiles before stowing to avoid conflicts.

## Scripts

This repository includes several utility scripts to assist with system setup.

### Install Tools (CachyOS)

This script automates the installation of commonly used tools and development utilities on CachyOS. It provides an easy way to manage packages and includes post-installation configuration for Docker, Rust, and LocalSend.

**Prerequisites:**

The script requires `paru` (an AUR helper) to be installed:

```shell
sudo pacman -S paru
```

**Usage:**

1.  **Make the script executable:**
    ```shell
    chmod +x scripts/install_tools-CachyOS.sh
    ```

2.  **Review available packages:**
    ```shell
    ./scripts/install_tools-CachyOS.sh --list
    ```

3.  **Run the script:**
    ```shell
    ./scripts/install_tools-CachyOS.sh
    ```
    
    The script will:
    - Display all packages to be installed (separated by source: repository and AUR)
    - Ask for confirmation before proceeding
    - Update your system
    - Install all packages
    - Configure Docker (add your user to the docker group)
    - Configure Rust (install stable toolchain if needed)
    - Configure firewall rules for LocalSend if applicable

**Available Options:**

```shell
./scripts/install_tools-CachyOS.sh --help              # Show help message
./scripts/install_tools-CachyOS.sh --list              # List packages without installing
./scripts/install_tools-CachyOS.sh --skip-confirmation # Skip confirmation prompt
```

**Customization:**

To add or remove packages, edit the configuration section at the top of the script:

1.  **Repository Packages:** Edit the `REPO_PKGS` array for packages from official CachyOS/Arch repositories
2.  **AUR Packages:** Edit the `AUR_PKGS` array for community-maintained packages from the Arch User Repository

Example - adding a new repository package:

```bash
REPO_PKGS=(
    git
    github-cli
    # ... existing packages ...
    neovim        # Add new package here
)
```

The arrays are clearly marked in the script and support comments for easy organization.

**Default Installed Packages:**

**Repository Packages:**
- **Development:** git, github-cli, lazygit, stow
- **Navigation:** zoxide
- **Container:** docker
- **Terminal & Shell:** starship
- **Applications:** obsidian, vlc, qbittorrent
- **Languages:** go, rustup
- **Editors:** zed
- **Utilities:** localsend, lazydocker

**AUR Packages:**
- microsoft-edge-stable-bin (proprietary web browser)

**What the script does:**

1.  Updates your system using `paru -Syu`
2.  Installs repository packages from official CachyOS/Arch repositories
3.  Installs AUR packages from the Arch User Repository
4.  Configures installed tools:
    - **Docker**: Enables the Docker service and adds your user to the docker group
    - **Rust**: Installs the stable Rust toolchain via rustup
    - **LocalSend**: Configures firewall rules (UFW or Firewalld) for port 53317

**Note:** If you installed Docker, you may need to log out and back in for the group changes to take effect.

### Nerd Fonts Install

This script automates the installation of [Nerd Fonts](https://www.nerdfonts.com/), which are essential for many terminal setups and code editors. The script provides an interactive interface for selecting fonts and supports both local and global installation.

**Prerequisites:**

Before running, ensure you have the following commands installed:
- `wget` - for downloading font files
- `unzip` - for extracting font archives
- `fc-cache` - for updating the font cache (provided by `fontconfig`)

On Arch-based systems (like CachyOS), install them using:

```shell
sudo pacman -S wget unzip fontconfig
```

On Debian-based systems:

```shell
sudo apt-get install wget unzip fontconfig
```

**Usage:**

1.  **Make the script executable:**
    ```shell
    chmod +x scripts/nerd-fonts-install.sh
    ```

2.  **Run the script:**
    ```shell
    ./scripts/nerd-fonts-install.sh
    ```

3.  **Follow the interactive prompts:**
    - The script will check for required dependencies and notify you if any are missing.
    - It will attempt to fetch the latest Nerd Fonts version from GitHub. If the network request fails, it will fall back to a default stable version.
    - Choose between **local installation** (recommended for most users, installs to `~/.local/share/fonts/NerdFonts`) or **global installation** (for all users, installs to `/usr/local/share/fonts/NerdFonts`).
    - A numbered list of available Nerd Fonts will be displayed. Select the fonts you want by entering their corresponding numbers separated by spaces (e.g., `1 5 12`).
    - Review your selection and confirm to proceed with the download and installation.
    - The script will download, extract, and install your selected fonts, then update the font cache.

**Examples:**

Install the Meslo font locally:
```shell
./scripts/nerd-fonts-install.sh
# When prompted, select "1" for local installation
# When shown the fonts list, enter the number corresponding to Meslo
```

Install multiple fonts (e.g., Meslo, FiraCode, and JetBrainsMono):
```shell
./scripts/nerd-fonts-install.sh
# When prompted, select "1" for local installation
# When shown the fonts list, enter the numbers for the fonts you want (e.g., "8 13 25")
```

**Notes:**

- Local installation is recommended as it doesn't require `sudo` and won't affect other users on the system.
- For global installation, the script will automatically request `sudo` privileges if needed.
- After installation, restart your terminal or applications to see the newly installed fonts.
- Each Nerd Font pack varies in size (typically 10-120 MB). Consider your bandwidth and storage when selecting multiple fonts.

## Directory Structure

Here's an overview of the directories within this repository and what they contain:

-   **`alacritty/`**: Configuration files for the [Alacritty](https://github.com/alacritty/alacritty) terminal emulator.
-   **`fish/`**: Configuration files for the [Fish shell](https://fishshell.com/).
-   **`git/`**: Global Git configurations (e.g., `~/.gitconfig`).
-   **`kitty/`**: Configuration files for the [Kitty](https://sw.kovidgoyal.net/kitty/) terminal emulator.
-   **`scripts/`**: Various utility scripts for system setup and maintenance.
-   **`starship/`**: Configuration for the [Starship](https://starship.rs/) prompt.
-   **`vim/`**: Configuration files for [Vim](https://www.vim.org/).
-   **`zed/`**: Configuration files for the [Zed](https://zed.dev/) editor.
