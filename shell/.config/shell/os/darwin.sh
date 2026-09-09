# shellcheck shell=bash
# macOS specific configuration

# Homebrew setup — probe known locations if brew isn't on PATH yet
# (non-login shells may not have /opt/homebrew/bin from .zprofile)
if [ -z "$HOMEBREW_PREFIX" ]; then
    if command -v brew >/dev/null 2>&1; then
        eval "$(brew shellenv)"
    else
        for _bp in /opt/homebrew /usr/local; do
            if [ -x "$_bp/bin/brew" ]; then
                eval "$("$_bp/bin/brew" shellenv)"
                break
            fi
        done
        unset _bp
    fi
fi

# macOS specific environment
export BROWSER="${BROWSER:-open}"
