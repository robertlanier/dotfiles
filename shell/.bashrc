# ~/.bashrc (managed by stow)

# 1) shared stuff for all shells/OS
[ -r "$HOME/.config/shell/common.sh" ] && . "$HOME/.config/shell/common.sh"

# 2) OS detection hooks (same logic as zsh)
if [ -r /etc/os-release ]; then
  . /etc/os-release
  [ -r "$HOME/.config/shell/os/linux.sh" ] && . "$HOME/.config/shell/os/linux.sh"
  [ -n "$ID" ] && [ -r "$HOME/.config/shell/os/$ID.sh" ] && . "$HOME/.config/shell/os/$ID.sh"
  # WSL overlay (loads after distribution-specific config)
  [ -r "$HOME/.config/shell/os/wsl.sh" ] && . "$HOME/.config/shell/os/wsl.sh"
else
  case "$(uname -s)" in
    Darwin) [ -r "$HOME/.config/shell/os/darwin.sh" ] && . "$HOME/.config/shell/os/darwin.sh" ;;
    Linux)  [ -r "$HOME/.config/shell/os/linux.sh" ]  && . "$HOME/.config/shell/os/linux.sh"  ;;
  esac
fi

# 3) bash-specific configuration
[ -r "$HOME/.config/bash/.bashrc" ] && . "$HOME/.config/bash/.bashrc"