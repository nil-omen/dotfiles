function fzf_smart_file_widget
    # Get the current token (word) at cursor (e.g., "src/")
    set -l token (commandline -t)

    # Default settings
    set -l search_dir "."
    set -l query ""

    # Logic: If token is a real directory, search inside it.
    if test -d "$token"
        set search_dir "$token"
    else
        set query "$token"
    end

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
