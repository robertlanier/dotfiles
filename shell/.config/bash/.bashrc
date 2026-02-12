# Main bash configuration
# This provides similar functionality to your zsh setup

# system info
fastfetch

# (History settings now handled globally in linux.sh)
# History configuration (similar to your zsh settings)
#export HISTSIZE=10000
#export HISTFILESIZE=20000
#export HISTCONTROL=ignoreboth  # Don't save duplicates or lines starting with space

# Enable color support
export FORCE_COLOR=1
export CLICOLOR=1

# Better completion
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
elif [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /usr/local/etc/bash_completion ]; then
    . /usr/local/etc/bash_completion
fi

# Use same starship prompt as zsh (if installed)
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi

# Enable fzf if installed (same as your zsh setup)
if [ -r "$HOME/.config/fzf/fzf.bash" ]; then
    . "$HOME/.config/fzf/fzf.bash"
elif command -v fzf >/dev/null 2>&1; then
    # Auto-detect fzf installation
    if [ -f ~/.fzf.bash ]; then
        . ~/.fzf.bash
    elif [ -f /usr/share/fzf/key-bindings.bash ]; then
        . /usr/share/fzf/key-bindings.bash
        . /usr/share/fzf/completion.bash
    fi
fi

# Restore git completion after fzf (fzf can override git's tab completion)
if [ -f /usr/share/bash-completion/completions/git ]; then
    . /usr/share/bash-completion/completions/git
elif [ -f /usr/local/etc/bash_completion.d/git-completion.bash ]; then
    . /usr/local/etc/bash_completion.d/git-completion.bash
fi

# Enable direnv if installed
if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook bash)"
fi
