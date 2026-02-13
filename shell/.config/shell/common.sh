# --- Shared across shells ---

# XDG Base Directory Specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Ensure XDG directories exist
mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"

# Source root for all repos (standardized across systems)
export SRC="$HOME/src"


# Add ~/.local/bin and ~/bin to PATH before system paths
[ -d "$HOME/.local/bin" ] && case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) PATH="$HOME/.local/bin:$PATH" ;; esac
[ -d "$HOME/bin" ] && case ":$PATH:" in *":$HOME/bin:"*) ;; *) PATH="$HOME/bin:$PATH" ;; esac
# --- SSH agent auto-start and key loading ---
if command -v ssh-agent >/dev/null 2>&1 && command -v ssh-add >/dev/null 2>&1; then
    # Only start agent if not already running
    if [ -z "$SSH_AUTH_SOCK" ] || ! ssh-add -l >/dev/null 2>&1; then
        # Try to find existing agent info
        if [ -f "$XDG_RUNTIME_DIR/ssh-agent.env" ]; then
            . "$XDG_RUNTIME_DIR/ssh-agent.env"
        fi
        # If still not running, start a new agent
        if [ -z "$SSH_AUTH_SOCK" ] || ! ssh-add -l >/dev/null 2>&1; then
            eval "$(ssh-agent -s)" > "$XDG_RUNTIME_DIR/ssh-agent.env"
            . "$XDG_RUNTIME_DIR/ssh-agent.env"
        fi
        # Add all private keys in ~/.ssh (skip public keys)
        if [ -d "$HOME/.ssh" ]; then
            for key in "$HOME/.ssh/"*; do
                case "$key" in
                    *.pub|*.crt|*.pem|*.txt) continue;;
                esac
                if grep -q 'PRIVATE KEY' "$key" 2>/dev/null; then
                    ssh-add "$key" 2>/dev/null
                fi
            done
        fi
    fi
fi

# Set editor to neovim
if command -v nvim >/dev/null 2>&1; then
    export EDITOR="nvim"
    export VISUAL="nvim"
    # Aliases for convenience
    alias vi="nvim"
    alias vim="nvim"
    alias vimdiff="nvim -d"
else
    export EDITOR="${EDITOR:-vi}"
    export VISUAL="${VISUAL:-vi}"
fi

# Git will use the EDITOR variable, but you can also set it explicitly
export GIT_EDITOR="$EDITOR"

# For programs that need a visual editor (like crontab -e)
export VISUAL="$EDITOR"
