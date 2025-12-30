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
    # ALIASES           #
    #####################

    # Navigation
    alias ..='cd ..'
    alias ...='cd ../..'
    alias ....='cd ../../..'
    alias .....='cd ../../../..'
    alias ......='cd ../../../../..'

    # Eza (Better LS)
    alias ls='eza -al --color=always --group-directories-first --icons=always'
    alias la='eza -a --color=always --group-directories-first --icons=always'
    alias ll='eza -l --color=always --group-directories-first --icons=always'
    alias lt='eza -aT --color=always --group-directories-first --icons=always'
    alias l.="eza -a | grep -e '^\.'"

    # Utilities
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    # Process management
    alias psmem='ps auxf | sort -nr -k 4'
    alias psmem10='ps auxf | sort -nr -k 4 | head -10'

    #####################
    # INITIALIZATION    #
    #####################

    # Greeting
    function fish_greeting
        # fastfetch
    end

    # Initialize tools
    zoxide init fish | source
    starship init fish | source

    # Set editor and visual
    set -gx EDITOR hx
    set -gx VISUAL hx
end
