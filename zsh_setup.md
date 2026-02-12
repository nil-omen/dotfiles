# Zsh Configuration Setup

This guide documents the creation and usage of the Zsh configuration ported from Fish.

## Installation

A script is provided to automate the installation of dependencies and plugins.

1.  **Run the Installer**:
    ```bash
    ~/dotfiles/scripts/install_zsh.sh
    ```
    To update/install plugins *only* (skipping system packages), run:
    ```bash
    ~/dotfiles/scripts/install_zsh.sh --plugins-only
    ```
    This script will:

    - Install `zsh`, `stow`, `fzf`, `zoxide`, `bat`, `eza`, `ripgrep`, `fd`.
    - Clone necessary Zsh plugins to `~/dotfiles/zsh/plugins`.
    - Run `stow zsh` to link configuration files to your home directory.

2.  **Set Zsh as Default Shell**:
    ```bash
    chsh -s $(which zsh)
    ```

3.  **Restart Shell**: Log out and back in, or just type `zsh`.

## Features

### Plugins
- **Syntax Highlighting**: Commands are highlighted as you type.
- **Autosuggestions**: Grey suggestions based on history (accept with Right Arrow).
- **History Substring Search**: Type part of a command and use Up/Down arrows to search history.
- **Sudo**: Press `Esc` twice to prepend `sudo` to the current command.
- **Auto Notify**: Get notifications when long-running commands finish (replacing `done.fish`).

### Custom Widgets & Keybindings
| Keybinding | Function | Description |
| :--- | :--- | :--- |
| `Alt + p` | `project_picker` | Quickly switch to projects in `~/projects`. Opens new tab in Zellij. |
| `Ctrl + t` | `fzf_smart_file_widget` | Smart file search using `fd` and `fzf`, inserts file path at cursor. |
| `Ctrl + r` | `fzf-history` | Search command history interactively. |
| `Alt + c` | `fzf-cd` | Search directories and `cd` into them. |
| `Up / Down` | `history-substring-search` | Search history matching current line buffer. |

### Helper Functions
- **backup [file]**: Creates `file.bak`.
- **copy [from] [to]**: Helper for `cp`.
- **gh-create**: Creates a private GitHub repo from the current directory.

## Directory Structure
- `~/dotfiles/zsh/.zshrc`: Main configuration.
- `~/dotfiles/zsh/.zshenv`: Environment variables.
- `~/dotfiles/zsh/aliases.zsh`: Aliases and abbreviations.
- `~/dotfiles/zsh/functions/`: Custom functions and widgets.
- `~/dotfiles/zsh/plugins/`: Git-ignored directory for plugin repos.

## Dependencies
Ensure these are installed (the script tries to install them):
- `fzf`
- `zoxide`
- `starship` (Prompt)
- `bat` (Cat clone with syntax highlighting)
- `eza` (Ls clone)
- `ripgrep` (Rg)
- `fd` (Find clone)
- `libnotify` / `notify-send` (For auto-notify plugin)
