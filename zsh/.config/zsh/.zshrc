# .zshrc: Interactive Shell Configuration

# Only run in interactive mode
[[ $- != *i* ]] && return

# ------------------------------------------------------------------------------
# 1. PLUGINS & HELPERS (Loaded first for functionality)
# ------------------------------------------------------------------------------

# Plugin directory
ZPLUGINDIR="$ZDOTDIR/plugins"

# Helper function to source plugins if they exist
function source_plugin() {
    local plugin_name="$1"
    local plugin_file="$2"
    if [[ -f "$ZPLUGINDIR/$plugin_name/$plugin_file" ]]; then
        source "$ZPLUGINDIR/$plugin_name/$plugin_file"
    else
        : 
    fi
}

# Source Plugins
# Source Plugins
# Manually source plugins from our directory

# Autocomplete (Should be loaded early)
if [[ -f "$ZPLUGINDIR/zsh-autocomplete/zsh-autocomplete.plugin.zsh" ]]; then
    source "$ZPLUGINDIR/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
fi

if [[ -f "$ZPLUGINDIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$ZPLUGINDIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if [[ -f "$ZPLUGINDIR/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
    source "$ZPLUGINDIR/zsh-history-substring-search/zsh-history-substring-search.zsh"
fi

if [[ -f "$ZPLUGINDIR/zsh-sudo/sudo.plugin.zsh" ]]; then
    source "$ZPLUGINDIR/zsh-sudo/sudo.plugin.zsh"
fi

# zsh-auto-notify requires notify-send
if command -v notify-send &> /dev/null; then
    if [[ -f "$ZPLUGINDIR/zsh-auto-notify/auto-notify.plugin.zsh" ]]; then
        source "$ZPLUGINDIR/zsh-auto-notify/auto-notify.plugin.zsh"
    fi
fi

# ------------------------------------------------------------------------------
# 2. PROMPT & TOOLS
# ------------------------------------------------------------------------------

# Initialize Starship
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# Initialize Zoxide (z)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# Initialize Direnv
if command -v direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
fi

# ------------------------------------------------------------------------------
# 3. OPTIONS & HISTORY
# ------------------------------------------------------------------------------

# History config
HISTSIZE=50000
SAVEHIST=50000
HISTFILE="$ZDOTDIR/.zsh_history" # Save history in config dir to keep home clean
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.

# Navigation
setopt AUTO_CD                   # If you type a directory name, cd into it.
setopt AUTO_PUSHD                # Make cd push the old directory onto the directory stack.
setopt PUSHD_IGNORE_DUPS         # Don't push multiple copies of the same directory onto the stack.

# ------------------------------------------------------------------------------
# 4. COMPLETION
# ------------------------------------------------------------------------------

autoload -Uz compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive
# Speed up completion with cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZDOTDIR/.zcompcache"

if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit -d "$ZDOTDIR/.zcompdump"
else
  compinit -C -d "$ZDOTDIR/.zcompdump"
fi

# ------------------------------------------------------------------------------
# 5. FUNCTIONS & WIDGETS
# ------------------------------------------------------------------------------

# Load custom functions
fpath=("$ZDOTDIR/functions" $fpath)
autoload -Uz backup copy gh-create project_picker fzf_smart_file_widget

# ------------------------------------------------------------------------------
# 6. KEYBINDINGS
# ------------------------------------------------------------------------------

# Set Vi mode (optional, but requested implicitly by "same workflow as fish" if fish was vi-mode. 
bindkey -e # Default to Emacs mode for now.

# History Substring Search (Up/Down) via plugin
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

# FZF History (Ctrl+R) - Standard fzf binding
if command -v fzf &> /dev/null; then
  source <(fzf --zsh)
fi

# FZF Smart File Widget (Ctrl+t)
zle -N fzf_smart_file_widget
bindkey '^t' fzf_smart_file_widget

# Project Picker (Alt+p)
zle -N project_picker
bindkey '^[p' project_picker

# ------------------------------------------------------------------------------
# 7. ALIASES
# ------------------------------------------------------------------------------
if [[ -f "$ZDOTDIR/aliases.zsh" ]]; then
    source "$ZDOTDIR/aliases.zsh"
fi

# ------------------------------------------------------------------------------
# 8. SYNTAX HIGHLIGHTING (MUST BE LAST)
# ------------------------------------------------------------------------------
if [[ -f "$ZPLUGINDIR/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]]; then
    source "$ZPLUGINDIR/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
fi

