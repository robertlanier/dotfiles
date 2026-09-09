# Cache Homebrew prefix once — must come first; PATH and plugin checks depend on it
if type brew &>/dev/null; then
    BREW_PREFIX=$(brew --prefix)
fi

# ------------- PATH -------------
# Prepend brew and /usr/local/sbin with dedup so subshells don't accumulate duplicates
if [ -n "$BREW_PREFIX" ]; then
    for _p in "$BREW_PREFIX/bin" "$BREW_PREFIX/sbin" /usr/local/sbin; do
        case ":$PATH:" in *":$_p:"*) ;; *) PATH="$_p:$PATH" ;; esac
    done
    unset _p
fi

# Fastfetch (system info) — after PATH so brew-installed fastfetch is found on macOS
command -v fastfetch &>/dev/null && fastfetch

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
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
zmodload zsh/complist                                          # must precede compinit
zstyle ':completion:*' menu select                            # must precede compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*'
autoload -Uz compinit
_zcd="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"
# Run full compinit if the dumpfile is missing or older than 24 hours;
# skip compaudit (-C) only when the dumpfile is confirmed fresh.
if [[ ! -f "$_zcd" ]] || [[ -n "$(find "$_zcd" -mtime +1 2>/dev/null)" ]]; then
    compinit -d "$_zcd"
else
    compinit -C -d "$_zcd"
fi
unset _zcd

# fzf-tab — must follow compinit but precede any plugin that wraps ZLE widgets
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh" ] && \
    source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh"

# ------------- Autosuggestions -------------
# shellcheck disable=SC2034  # zsh reads these variables internally
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

if [ -n "$BREW_PREFIX" ] && [ -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# ------------- History -------------
export HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
mkdir -p "${HISTFILE:h}"

# shellcheck disable=SC2034  # zsh reads HISTSIZE and SAVEHIST internally
HISTSIZE=100000
# shellcheck disable=SC2034
SAVEHIST=100000
setopt append_history extended_history hist_ignore_all_dups hist_reduce_blanks share_history hist_ignore_space

# ------------- Behavior Tweaks -------------
setopt auto_cd auto_list auto_menu always_to_end extended_glob
unsetopt correct_all

# saner word motions
# shellcheck disable=SC2034  # WORDCHARS is read by zsh internally
WORDCHARS='*?_[]~=&;!#$%^(){}'

# ------------- Navigation & Fuzzy -------------
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh --cmd cd)"
fi

# FZF shell integration — XDG path first, then built-in (fzf >= 0.48), then fallbacks
if [ -r "$HOME/.config/fzf/fzf.zsh" ]; then
    source "$HOME/.config/fzf/fzf.zsh"
elif command -v fzf &>/dev/null; then
    # Capture output once to avoid two forks for probe + generate
    if _fzf_init=$(fzf --zsh 2>/dev/null); then
        eval "$_fzf_init"
    elif [ -f "$HOME/.fzf.zsh" ]; then
        source "$HOME/.fzf.zsh"
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
    unset _fzf_init
fi

# FZF Theme: Catppuccin Macchiato
export FZF_THEME_FILE="$HOME/.config/fzf/themes/catppuccin/themes/catppuccin-fzf-macchiato.sh"
[ -f "$FZF_THEME_FILE" ] && source "$FZF_THEME_FILE"

# ------------- Syntax Highlighting (must be last) -------------
# fast-syntax-highlighting wraps every ZLE widget chain present at source time —
# anything sourced after it loses highlighting on its widgets.
export FAST_HIGHLIGHT_STYLES_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/plugins/zsh-fsh/themes"
export FAST_THEME='catppuccin_macchiato'

_fsh_local="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/plugins/zsh-fsh/fast-syntax-highlighting.plugin.zsh"
if [ -f "$_fsh_local" ]; then
    source "$_fsh_local"
elif [ -n "$BREW_PREFIX" ] && [ -f "$BREW_PREFIX/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]; then
    source "$BREW_PREFIX/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
elif [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
unset _fsh_local
