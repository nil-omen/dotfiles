if status is-interactive
    # Commands to run in interactive sessions can go here
end
fastfetch
set -g fish_greeting
starship init fish | source
# added path for go
fish_add_path /usr/local/go/bin
# and now go binaries
fish_add_path $HOME/go/bin
# added path to rust
fish_add_path $HOME/.cargo/bin
# added zoxide support
zoxide init fish | source
# added path to neovim
fish_add_path /opt/nvim-linux-x86_64/bin
