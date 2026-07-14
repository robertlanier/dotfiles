# shellcheck shell=bash
# macOS specific configuration

# Homebrew setup — skip if already initialized by .zprofile/.bash_profile (login shells)
if [ -z "$HOMEBREW_PREFIX" ] && command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
fi

# macOS specific environment
export BROWSER="open"
