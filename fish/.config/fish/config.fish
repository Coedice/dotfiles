# Ruby path
set -gx PATH /opt/homebrew/opt/ruby/bin $PATH

if status is-interactive
    # Commands to run in interactive sessions can go here
end

thefuck --alias | source
starship init fish | source


# Created by `pipx` on 2025-05-24 15:00:55
set PATH $PATH /Users/Gavin/.local/bin

