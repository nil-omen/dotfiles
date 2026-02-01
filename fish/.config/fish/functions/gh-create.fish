function gh-create
    # Creates new private repo with the same name as the current folder.
    # Then links the remote to the local and pushes, then opens the browser.
    # You need to initialize a git repo first with `git init`

    # Check for required tools
    if not type -q git
        echo "Error: git is not installed. Please install git first."
        return 1
    end

    if not type -q gh
        echo "Error: gh (GitHub CLI) is not installed. Please install it first."
        echo "  → https://cli.github.com/"
        return 1
    end

    # Check if we're in a git repository
    if not test -d .git
        echo "Error: Not a git repository. Run 'git init' first."
        return 1
    end

    gh repo create --private --source=. --remote=origin && git push -u --all && gh browse $argv
end
