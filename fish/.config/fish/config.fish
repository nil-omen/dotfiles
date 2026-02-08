# Load Nix environment
if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
end
# Fallback for single-user installs
if test -e ~/.nix-profile/etc/profile.d/nix.fish
    source ~/.nix-profile/etc/profile.d/nix.fish
end

if status is-interactive

    #####################
    # CACHYOS / ARCH    #
    #####################
    # These are commented out for NixOS compatibility.
    # Uncomment if you switch back to CachyOS.
    # source /usr/share/cachyos-fish-config/cachyos-config.fish
    # source /usr/share/cachyos-fish-config/conf.d/done.fish

    #####################
    # ENVIRONMENT & PATH #
    #####################

    # Add custom paths
    fish_add_path ~/.local/bin
    fish_add_path ~/.cargo/bin
    fish_add_path ~/go/bin
    fish_add_path /usr/local/go/bin
    fish_add_path /opt/nvim-linux-x86_64/bin
    fish_add_path ~/Applications/depot_tools

    # NixOS Specific: Allow unfree packages (e.g., for 'nix run')
    # The check ensures this only runs on NixOS, ignoring CachyOS/Arch
    if test -f /etc/NIXOS
        set -gx NIXPKGS_ALLOW_UNFREE 1
    end

    # Format man pages (requires 'bat' installed)
    set -x MANROFFOPT -c
    set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

    #####################
    # SETTINGS: "DONE"  #
    #####################
    set -U __done_min_cmd_duration 10000
    set -U __done_notification_urgency_level low

    #####################
    # HISTORY HELPERS   #
    #####################
    
    # History Expansion (!! and !$)
    # Kept here as they are tightly coupled to bindings

    function __history_previous_command
        switch (commandline -t)
            case "!"
                commandline -t $history[1]
                commandline -f repaint
                commandline -f repaint
            case "*"
                commandline -i !
        end
    end

    function __history_previous_command_arguments
        switch (commandline -t)
            case "!"
                commandline -t ""
                commandline -f history-token-search-backward
            case "*"
                commandline -i '$'
        end
    end

    # History helper bindings
    if [ "$fish_key_bindings" = fish_vi_key_bindings ]
        bind -Minsert ! __history_previous_command
        bind -Minsert '$' __history_previous_command_arguments
    else
        bind ! __history_previous_command
        bind '$' __history_previous_command_arguments
    end

    #####################
    # ABBREVIATIONS     #
    #####################
    # 'abbr' is preferred over 'alias' in Fish.
    # It expands the command in your prompt before you run it.

    # Navigation
    abbr --add .. 'cd ..'
    abbr --add ... 'cd ../..'
    abbr --add .... 'cd ../../..'

    # Eza (LS replacement)
    # Using 'abbr' means when you type 'll', it expands to the full eza command
    abbr --add ls 'eza -al --color=always --group-directories-first --icons=always'
    abbr --add la 'eza -a --color=always --group-directories-first --icons=always'
    abbr --add ll 'eza -l --color=always --group-directories-first --icons=always'
    abbr --add lt 'eza -aT --color=always --group-directories-first --icons=always'

    # Git
    abbr --add gs 'git status'
    abbr --add ga 'git add .'
    abbr --add gc 'git commit -m'
    abbr --add gp 'git push'

    # Utilities
    abbr --add pstop 'ps auxf | sort -nr -k 4 | head -10'
    abbr --add lg lazygit
    abbr --add ld lazydocker

    # Colorize help pages with bat
    # Use \-h or \--help to escape when needed (e.g., ls \-h)
    abbr --add --position anywhere -- --help '--help 2>&1 | bat -plhelp'
    abbr --add --position anywhere -- -h '-h 2>&1 | bat -plhelp'


    # Force sudo to use the current user's helix path
    abbr --add suhx 'sudo (which hx)'

    #####################
    # INITIALIZATION    #
    #####################

    # Initialize tools
    if type -q zoxide; zoxide init fish | source; end
    if type -q starship; starship init fish | source; end
    if type -q direnv; direnv hook fish | source; end

    # Set editor and visual
    set -gx EDITOR hx
    set -gx VISUAL hx

    #####################
    # FZF CONFIG        #
    #####################

    # 1. Enable FZF keybindings (Ctrl+R history, Ctrl+T files, Alt+C cd)
    # This requires fzf 0.48.0+ (standard on Arch/NixOS)
    if type -q fzf
        fzf --fish | source
    end

    # 2. Use 'fd' (if installed) instead of 'find'
    # This makes fzf much faster and respect .gitignore
    if type -q fd
        # Default/Ctrl+T: Files only
        set -gx FZF_DEFAULT_COMMAND 'fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
        set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"

        # Alt+C: Directories only (makes Alt+C much faster)
        set -gx FZF_ALT_C_COMMAND 'fd --type d --strip-cwd-prefix --hidden --follow --exclude .git'
    end

    # 3. Visual Styling
    set -gx FZF_DEFAULT_OPTS "
        --layout=reverse
        --border
        --height=90%
        --preview 'bat --style=numbers --color=always --line-range :500 {}'
        --preview-window 'right:60%'
        --bind 'ctrl-/:toggle-preview'
    "

    # 4. Specific Overrides

    # HISTORY (Ctrl+R): No preview
    set -gx FZF_CTRL_R_OPTS "--preview-window=hidden"

    # DIRECTORIES (Alt+C): Preview with Eza Tree
    # Shows a tree view of the folder content. 
    # 'head -200' prevents lag on massive directories (like node_modules)
    set -gx FZF_ALT_C_OPTS "--preview 'eza --tree --level=2 --color=always {} | head -200'"

    # Bind Ctrl+T to the autoloaded function
    bind -M insert \ct fzf_smart_file_widget # For Vi Insert Mode
    bind \ct fzf_smart_file_widget # For Normal/Default Mode
end
