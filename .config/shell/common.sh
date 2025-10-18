# --- Shared across shells ---
# Add ~/bin to PATH if it exists
[ -d "$HOME/bin" ] && case ":$PATH:" in *":$HOME/bin:"*) ;; *) PATH="$HOME/bin:$PATH";; esac
export EDITOR="${EDITOR:-vim}"
