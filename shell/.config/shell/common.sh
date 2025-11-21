# --- Shared across shells ---
# Add ~/bin to PATH if it exists
[ -d "$HOME/bin" ] && case ":$PATH:" in *":$HOME/bin:"*) ;; *) PATH="$HOME/bin:$PATH";; esac

# Set editor preference: neovim > vim
if command -v nvim >/dev/null 2>&1; then
    export EDITOR="nvim"
    export VISUAL="nvim"
    # Aliases for convenience
    alias vi="nvim"
    alias vim="nvim"
    alias vimdiff="nvim -d"
elif command -v vim >/dev/null 2>&1; then
    export EDITOR="vim"
    export VISUAL="vim"
else
    export EDITOR="${EDITOR:-vi}"
    export VISUAL="${VISUAL:-vi}"
fi

# Git will use the EDITOR variable, but you can also set it explicitly
export GIT_EDITOR="$EDITOR"

# For programs that need a visual editor (like crontab -e)
export VISUAL="$EDITOR"
