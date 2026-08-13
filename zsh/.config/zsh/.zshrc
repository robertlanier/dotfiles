# Fastfetch (system info)
command -v fastfetch &>/dev/null && fastfetch

# Cache Homebrew prefix once to avoid repeated subprocess forks
if type brew &>/dev/null; then
    BREW_PREFIX=$(brew --prefix)
fi

# ------------- PATH -------------
if [ -n "$BREW_PREFIX" ]; then
    export PATH="$BREW_PREFIX/bin:$BREW_PREFIX/sbin:/usr/local/sbin:$PATH"
fi

# ------------- Prompt -------------
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# Enable direnv if installed
if command -v direnv &>/dev/null; then
    eval "$(direnv hook zsh)"
fi

# ------------- Completions -------------
if [ -n "$BREW_PREFIX" ]; then
    FPATH="$BREW_PREFIX/share/zsh-completions:$FPATH"
fi
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
zmodload zsh/complist

# ------------- Autosuggestions & Syntax Highlighting -------------
# shellcheck disable=SC2034  # zsh reads these variables internally
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

if [ -n "$BREW_PREFIX" ] && [ -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Set FSH theme vars BEFORE sourcing (required for theme to apply)
export FAST_HIGHLIGHT_STYLES_DIR="$HOME/.config/zsh/plugins/zsh-fsh/themes"
export FAST_THEME='catppuccin_macchiato'

if [ -n "$BREW_PREFIX" ] && [ -f "$BREW_PREFIX/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]; then
    source "$BREW_PREFIX/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
elif [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# ------------- History -------------
export HISTFILE="$XDG_STATE_HOME/zsh/history"
mkdir -p "${HISTFILE:h}"

# shellcheck disable=SC2034  # zsh reads HISTSIZE and SAVEHIST internally
HISTSIZE=100000
# shellcheck disable=SC2034
SAVEHIST=100000
setopt append_history extended_history hist_ignore_all_dups hist_reduce_blanks share_history hist_ignore_space

# ------------- Completion -------------
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*'

[ -f ~/.config/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh ] && source ~/.config/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh

# ------------- Behavior Tweaks -------------
setopt auto_cd auto_list auto_menu always_to_end
unsetopt correct_all

# saner word motions
# shellcheck disable=SC2034  # WORDCHARS is read by zsh internally
WORDCHARS='*?_[]~=&;!#$%^(){}'

# ------------- Navigation & Fuzzy -------------
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# FZF shell integration — XDG path first, then built-in (fzf >= 0.48), then fallbacks
if [ -r "$HOME/.config/fzf/fzf.zsh" ]; then
    source "$HOME/.config/fzf/fzf.zsh"
elif command -v fzf &>/dev/null; then
    if fzf --zsh >/dev/null 2>&1; then
        eval "$(fzf --zsh)"
    elif [ -f ~/.fzf.zsh ]; then
        source ~/.fzf.zsh
    elif [ -f /usr/share/fzf/key-bindings.zsh ]; then
        source /usr/share/fzf/key-bindings.zsh
        [ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
    elif [ -f /usr/share/fzf/shell/key-bindings.zsh ]; then
        # shellcheck source=/dev/null
        source /usr/share/fzf/shell/key-bindings.zsh
        # shellcheck source=/dev/null
        [ -f /usr/share/fzf/shell/completion.zsh ] && source /usr/share/fzf/shell/completion.zsh
    elif [ -n "$BREW_PREFIX" ] && [ -f "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ]; then
        source "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
        [ -f "$BREW_PREFIX/opt/fzf/shell/completion.zsh" ] && source "$BREW_PREFIX/opt/fzf/shell/completion.zsh"
    fi
fi

# FZF Theme: Catppuccin Macchiato
export FZF_THEME_FILE="$HOME/.config/fzf/themes/catppuccin/themes/catppuccin-fzf-macchiato.sh"
[ -f "$FZF_THEME_FILE" ] && source "$FZF_THEME_FILE"
