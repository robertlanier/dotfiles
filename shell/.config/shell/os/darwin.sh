# macOS specific configuration
# Homebrew setup (if using Homebrew)
if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
fi

# macOS specific environment
export BROWSER="open"
