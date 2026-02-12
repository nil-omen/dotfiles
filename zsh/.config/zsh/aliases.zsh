# Aliases
# Ported from Fish config

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Eza (LS replacement)
alias ls='eza -al --color=always --group-directories-first --icons=always'
alias la='eza -a --color=always --group-directories-first --icons=always'
alias ll='eza -l --color=always --group-directories-first --icons=always'
alias lt='eza -aT --color=always --group-directories-first --icons=always'

# Git
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'

# Utilities
alias pstop='ps auxf | sort -nr -k 4 | head -10'
alias lg='lazygit'
alias ld='lazydocker'

# Colorize help pages with bat
alias -g -- --help='--help 2>&1 | bat -plhelp'
alias -g -- -h='-h 2>&1 | bat -plhelp'

# Force sudo to use the current user's helix path
alias suhx='sudo $(which hx)'
