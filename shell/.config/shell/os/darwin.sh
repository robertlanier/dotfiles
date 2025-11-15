# macOS specific configuration
# Homebrew setup (if using Homebrew)
if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
fi

# Path additions for macOS
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"

# macOS specific environment
export BROWSER="open"