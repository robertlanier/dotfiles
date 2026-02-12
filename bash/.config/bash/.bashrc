# Enable direnv if installed
if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook bash)"
fi

# Main bash configuration
# This provides similar functionality to your zsh setup

# system info
command -v fastfetch >/dev/null 2>&1 && fastfetch

# ------------- History (XDG-compliant) -------------
export HISTFILE="$XDG_STATE_HOME/bash/history"
mkdir -p "${HISTFILE%/*}" # Create directory if it doesn't exist
export HISTSIZE=100000
export HISTFILESIZE=200000
export HISTCONTROL=ignoreboth # Don't save duplicates or lines starting with space
export HISTTIMEFORMAT="%F %T "

# Enable color support
export FORCE_COLOR=1
export CLICOLOR=1

# FZF Theme: Catppuccin Macchiato (shared with zsh)
export FZF_THEME_FILE="$HOME/.config/fzf/themes/catppuccin/themes/catppuccin-fzf-macchiato.sh"
[ -f "$FZF_THEME_FILE" ] && . "$FZF_THEME_FILE"

# Better completion (Linux + macOS Homebrew)
for bash_completion_file in \
    /etc/bash_completion \
    /usr/share/bash-completion/bash_completion \
    /usr/local/etc/bash_completion \
    /usr/local/etc/profile.d/bash_completion.sh \
    /opt/homebrew/etc/profile.d/bash_completion.sh; do
    if [ -f "$bash_completion_file" ]; then
        . "$bash_completion_file"
        break
    fi
done

# Enable ble.sh if installed (interactive bash only)
if [[ $- == *i* ]]; then
    for blesh_file in \
        "$HOME/.local/share/blesh/ble.sh" \
        /usr/share/blesh/ble.sh \
        /usr/local/share/blesh/ble.sh \
        /opt/homebrew/share/blesh/ble.sh; do
        if [ -f "$blesh_file" ]; then
            # Source once and attach the interactive editor.
            [ -n "${BLE_VERSION-}" ] || source "$blesh_file" --noattach
            command -v ble-attach >/dev/null 2>&1 && ble-attach
            # Optional local ble.sh theme override (Catppuccin, etc.)
            BLE_THEME_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/blesh/themes/catppuccin-macchiato.bash"
            [ -f "$BLE_THEME_FILE" ] && source "$BLE_THEME_FILE"
            break
        fi
    done
fi

# Use same starship prompt as zsh (if installed)
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi

# Enable fzf if installed (same as your zsh setup)
if [ -r "$HOME/.config/fzf/fzf.bash" ]; then
    . "$HOME/.config/fzf/fzf.bash"
elif command -v fzf >/dev/null 2>&1; then
    # Prefer built-in shell integration when available (fzf >= 0.48).
    if fzf --bash >/dev/null 2>&1; then
        eval "$(fzf --bash)"
    elif [ -f ~/.fzf.bash ]; then
        . ~/.fzf.bash
    elif [ -f /usr/share/fzf/key-bindings.bash ]; then
        . /usr/share/fzf/key-bindings.bash
        [ -f /usr/share/fzf/completion.bash ] && . /usr/share/fzf/completion.bash
    elif [ -f /usr/share/fzf/shell/key-bindings.bash ]; then
        . /usr/share/fzf/shell/key-bindings.bash
        [ -f /usr/share/fzf/shell/completion.bash ] && . /usr/share/fzf/shell/completion.bash
    elif [ -f /usr/local/opt/fzf/shell/key-bindings.bash ]; then
        . /usr/local/opt/fzf/shell/key-bindings.bash
        [ -f /usr/local/opt/fzf/shell/completion.bash ] && . /usr/local/opt/fzf/shell/completion.bash
    elif [ -f /opt/homebrew/opt/fzf/shell/key-bindings.bash ]; then
        . /opt/homebrew/opt/fzf/shell/key-bindings.bash
        [ -f /opt/homebrew/opt/fzf/shell/completion.bash ] && . /opt/homebrew/opt/fzf/shell/completion.bash
    fi
fi

# Restore git completion after fzf (fzf can override git's tab completion)
for git_completion_file in \
    /usr/share/bash-completion/completions/git \
    /usr/local/etc/bash_completion.d/git-completion.bash \
    /opt/homebrew/etc/bash_completion.d/git-completion.bash \
    /usr/local/share/bash-completion/completions/git \
    /opt/homebrew/share/bash-completion/completions/git; do
    if [ -f "$git_completion_file" ]; then
        . "$git_completion_file"
        break
    fi
done
