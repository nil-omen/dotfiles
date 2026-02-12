# .zshenv: Environment variables
# This runs for EVERY shell (interactive or not). Keep it light.

# Ensure PATH includes local bins
typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  "$HOME/go/bin"
  "/usr/local/go/bin"
  "/opt/nvim-linux-x86_64/bin"
  "$HOME/Applications/depot_tools"
  "$path[@]"
)
export PATH

# Set ZDOTDIR to keep home directory clean
export ZDOTDIR="$HOME/.config/zsh"

# Editor
export EDITOR='hx'
export VISUAL='hx'

# NixOS Allow Unfree (if on NixOS)
if [[ -f /etc/NIXOS ]]; then
    export NIXPKGS_ALLOW_UNFREE=1
fi

# Manpage coloring (bat)
export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
