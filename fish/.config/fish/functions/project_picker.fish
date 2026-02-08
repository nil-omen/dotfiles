function project_picker --description "Switch to a project directory in Zellij"
    set -l query $argv[1]
    set -l ratio_threshold 3
    set -l projects_dir ~/projects

    # Check if ~/projects exists
    if not test -d $projects_dir
        echo "Error: ~/projects directory doesn't exist" >&2
        commandline -f repaint
        return 1
    end

    # Get all projects with zoxide scores, sorted by frecency
    # Query all zoxide entries (already sorted by score), filter to projects dir
    set -l projects_expanded (string replace '~' $HOME $projects_dir)
    set -l results (
        zoxide query -l -s 2>/dev/null |
        rg "$projects_expanded/" |
        string replace -a "$projects_expanded/" "" |
        string match -rv "^\s*[\d.]+\s*\$"
    )

    # If no results from zoxide, fall back to fd listing with zero scores
    if test -z "$results"
        set results (fd --type d --max-depth 1 --base-directory $projects_dir | while read dir; echo "   0.0 $dir"; end)
    end

    # If still nothing, exit
    if test -z "$results"
        echo "No projects found in ~/projects" >&2
        commandline -f repaint
        return 1
    end

    set -l selected

    # If a query was provided, try to auto-select based on score ratio
    if test -n "$query"
        set -l filtered (printf '%s\n' $results | fzf --no-sort --filter="$query")
        if test (count $filtered) -ge 1
            set -l scores (printf '%s\n' $filtered | string match -r '^\s*[\d.]+' | string trim)
            set -l top $scores[1]
            set -l second 0
            test (count $scores) -ge 2 && set second $scores[2]

            # Auto-select if second score is 0, or ratio is >= threshold
            if test "$second" = "0"; or test (math "$top / $second") -ge $ratio_threshold
                set selected (echo $filtered[1] | awk '{print $2}')
            end
        end
    end

    # If not auto-selected, use interactive fzf
    if test -z "$selected"
        set selected (printf '%s\n' $results | awk '{print $2}' | fzf \
            --no-sort \
            --select-1 \
            --query="$query" \
            --prompt="  " \
            --height=40% \
            --border \
            --preview="eza --tree --level=2 --color=always $projects_dir/{} 2>/dev/null || ls -la $projects_dir/{}" \
            --preview-window=right:50%)
    end

    # If nothing selected, exit and repaint
    if test -z "$selected"
        commandline -f repaint
        return 0
    end

    set -l project_path "$projects_dir/$selected"

    # Update zoxide database
    zoxide add "$project_path"

    # Check if we're inside Zellij
    if not set -q ZELLIJ
        cd "$project_path"
        commandline -f repaint
        return 0
    end

    # Create a new Zellij tab with the project name
    zellij action new-tab --layout default --name "$selected" --cwd "$project_path"
    commandline -f repaint
end
