# Fastfetch (system info)
fastfetch

# ------------- Prompt -------------
eval "$(starship init zsh)"

# ------------- Homebrew completions -------------
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh-completions:$FPATH"
  # XDG-compliant completion cache
  autoload -Uz compinit
  compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
  zmodload zsh/complist
fi

# ------------- Autosuggestions & Syntax Highlighting -------------
# Subtle autosuggestions (soft gray)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Fast syntax highlighting (load AFTER autosuggestions) + Catppuccin Theme
source "$(brew --prefix)/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
export FAST_HIGHLIGHT_STYLES_DIR="$HOME/.config/zsh/plugins/zsh-fsh/themes"
export FAST_THEME='catppuccin_macchiato'   # or latte/frappe/macchiato

# ------------- History -------------
# XDG-compliant history location
export HISTFILE="$XDG_STATE_HOME/zsh/history"
mkdir -p "${HISTFILE:h}"  # Create directory if it doesn't exist

HISTSIZE=100000
SAVEHIST=100000
setopt append_history
setopt extended_history
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt inc_append_history
setopt share_history
setopt hist_ignore_space

# ------------- Completion -------------
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*'

# Load fzf-tab (manual install path)
source ~/.config/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh

# ------------- Behavior Tweaks -------------
setopt auto_cd
setopt auto_list
setopt auto_menu
setopt always_to_end
# setopt correct       # OPTIONAL: command-name correction only
unsetopt correct_all   # avoid noisy autocorrect

# saner word motions
WORDCHARS='*?_[]~=&;!#$%^(){}'

# ------------- Navigation & Fuzzy -------------
# Jump by memory (cd replacement)
eval "$(zoxide init zsh)"

# FZF: use ctrl+r for history search menu
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# FZF Theme: Catppuccin Mocha
export FZF_THEME_FILE="$HOME/.config/fzf/themes/catppuccin/themes/catppuccin-fzf-macchiato.sh"
if [ -f "$FZF_THEME_FILE" ]; then
  source "$FZF_THEME_FILE"
fi

# ------------- PATH -------------
export PATH="$(brew --prefix)/bin:$(brew --prefix)/sbin:/usr/local/sbin:$PATH"

# ------------- Aliases (add yours below) -------------
