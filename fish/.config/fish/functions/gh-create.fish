function gh-create
    # Creates new private repo with the same name as the current folder. then links the remote to the local and pushes. then opens the browser
    # You need to initialize a git repo first
    # # use `git init`
    gh repo create --private --source=. --remote=origin && git push -u --all && gh browse $argv
end
