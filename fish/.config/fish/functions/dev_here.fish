function dev_here --description "Launch a local Zellij session in the current directory"
    # Allow an optional directory argument, defaulting to the current working directory
    set -l target_dir "$PWD"
    if test (count $argv) -gt 0
        set target_dir $argv[1]
    end

    # Change to target directory
    cd "$target_dir" || return 1

    # Extract the folder name to use as the Zellij session name
    set -l session_name (basename "$PWD")

    # Fallback if at filesystem root
    if test -z "$session_name" -o "$session_name" = "/"
        set session_name "root"
    end

    # Attach to or create the Zellij session with the mobile-dev layout
    zellij --layout mobile-dev attach -c "$session_name"
end
