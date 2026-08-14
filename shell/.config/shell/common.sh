# shellcheck shell=bash
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

# Add cargo bin to PATH
[ -d "$HOME/.cargo/bin" ] && case ":$PATH:" in *":$HOME/.cargo/bin:"*) ;; *) PATH="$HOME/.cargo/bin:$PATH" ;; esac

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

# Use bat as a cat replacement when available
# Ubuntu/Debian package the binary as batcat to avoid a naming conflict
if command -v bat >/dev/null 2>&1; then
    alias cat="bat"
elif command -v batcat >/dev/null 2>&1; then
    alias cat="batcat"
    alias bat="batcat"
fi

# Machine-local overrides (not tracked in repo — put work/machine-specific config here)
# shellcheck source=/dev/null
[ -f "$XDG_CONFIG_HOME/shell/local.sh" ] && . "$XDG_CONFIG_HOME/shell/local.sh"
