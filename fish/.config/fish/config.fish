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
    set -x MANROFFOPT "-c"
    set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

    #####################
    # SETTINGS: "DONE"  #
    #####################
    set -U __done_min_cmd_duration 10000
    set -U __done_notification_urgency_level low

    #####################
    # FUNCTIONS         #
    #####################

    # Quick Backup
    function backup --argument filename
        cp $filename $filename.bak
    end

    # Smart Copy
    function copy
        set count (count $argv | tr -d \n)
        if test "$count" = 2; and test -d "$argv[1]"
            set from (echo $argv[1] | string trim --right /)
            set to (echo $argv[2])
            command cp -r $from $to
        else
            command cp $argv
        end
    end

    # History Expansion (!! and !$)
    function __history_previous_command
        switch (commandline -t)
        case "!"
            commandline -t $history[1]; commandline -f repaint
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
    if [ "$fish_key_bindings" = fish_vi_key_bindings ];
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

    # Git (Common workflow boosters)
    abbr --add gs 'git status'
    abbr --add ga 'git add .'
    abbr --add gc 'git commit -m'
    abbr --add gp 'git push'

    # Utilities
    abbr --add pstop 'ps auxf | sort -nr -k 4 | head -10'

    #####################
    # INITIALIZATION    #
    #####################

    # Greeting
    function fish_greeting
        # fastfetch
    end

    # Initialize tools
    if type -q zoxide; zoxide init fish | source; end
    if type -q starship; starship init fish | source; end

    # Set editor and visual
    set -gx EDITOR hx
    set -gx VISUAL hx


    #####################
    # FZF MANUAL SETUP  #
    #####################

    # 1. Enable FZF keybindings (Ctrl+R history, Ctrl+T files, Alt+C cd)
    # This requires fzf 0.48.0+ (standard on Arch/NixOS)
    if type -q fzf
        fzf --fish | source
    end

    # 2. Use 'fd' (if installed) instead of 'find'
    # This makes fzf much faster and respect .gitignore
    if type -q fd
        set -gx FZF_DEFAULT_COMMAND 'fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
        set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    end

    # 3. Visual Styling (Matches your modern setup)
    # layout=reverse: Search bar at top, lists down
    # border: Adds a nice border
    set -gx FZF_DEFAULT_OPTS "
        --layout=reverse
        --border
        --height=90%
        --preview 'bat --style=numbers --color=always --line-range :500 {}'
        --preview-window 'right:60%'
        --bind 'ctrl-/:toggle-preview'
    "
    function fzf_smart_file_widget
        # Get the current token (word) at cursor (e.g., "src/")
        set -l token (commandline -t)

        # Default settings
        set -l search_dir "."
        set -l query ""

        # Logic: If token is a real directory, search inside it.
        # Otherwise, use the token as the fuzzy search query.
        if test -d "$token"
            set search_dir "$token"
        else
            set query "$token"
        end

        # FIX: Define command as a LIST (no quotes around the whole line)
        # This ensures Fish sees 'fd' as the command and the rest as arguments.
        if type -q fd
            set command fd --type f --hidden --follow --exclude .git . $search_dir
        else
            set command find $search_dir -type f
        end

        # Execute the list ($command) -> pipe to fzf
        set -l result ($command | fzf --query "$query" --height=40% --layout=reverse --border --preview 'bat --style=numbers --color=always {}')

        # If we selected something, replace the token with the result
        if test -n "$result"
            commandline -t -- $result
        end

        commandline -f repaint
    end
    # Bind Ctrl+T to this new smart function
    bind -M insert \ct fzf_smart_file_widget  # For Vi Insert Mode
    bind \ct fzf_smart_file_widget            # For Normal/Default Mode
end
