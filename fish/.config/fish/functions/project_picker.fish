function project_picker --description "Switch to a project directory in Zellij"
    set -l projects_dir ~/projects
    
    # Check if ~/projects exists
    if not test -d $projects_dir
        echo "Error: ~/projects directory doesn't exist"
        return 1
    end
    
    # Get all projects with zoxide scores, sorted by frecency
    # For each top-level dir in projects, query zoxide for matches
    set -l results (
        find "$projects_dir" -maxdepth 1 -type d |
        while read dir
            zoxide query -l -s "$dir/" 2>/dev/null
        end |
        sed "s;$projects_dir/;;" |
        grep -v "^$projects_dir\$" |
        grep -v "^\s*[0-9.]*\s*\$" |
        sort -rnk1 |
        uniq
    )
    
    # If no results from zoxide, fall back to fd listing
    if test -z "$results"
        set results (fd --type d --max-depth 1 --base-directory $projects_dir | sed 's/^/   0.0 /')
    end
    
    # If still nothing, exit
    if test -z "$results"
        echo "No projects found in ~/projects"
        return 1
    end
    
    # Use fzf to select (--no-sort preserves our frecency order)
    set -l selected (printf '%s\n' $results | awk '{print $2}' | fzf \
        --no-sort \
        --prompt="Select Project: " \
        --height=40% \
        --border \
        --preview="eza --tree --level=2 --color=always $projects_dir/{} 2>/dev/null || ls -la $projects_dir/{}" \
        --preview-window=right:50%)
    
    # If nothing selected, exit
    if test -z "$selected"
        return 0
    end
    
    set -l project_path "$projects_dir/$selected"
    
    # Update zoxide database
    zoxide add "$project_path"
    
    # Check if we're inside Zellij
    if not set -q ZELLIJ
        cd "$project_path"
        return 0
    end
    
    # Create a new Zellij tab with the project name
    zellij action new-tab --layout default --name "$selected" --cwd "$project_path"
end
