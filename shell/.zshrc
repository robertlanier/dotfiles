# ~/.zshrc (managed by stow)

# 1) shared stuff for all shells/OS
[ -r "$HOME/.config/shell/common.sh" ] && . "$HOME/.config/shell/common.sh"

# 2) OS detection hooks (optional files you may add later)
if [ -r /etc/os-release ]; then
  . /etc/os-release
  [ -r "$HOME/.config/shell/os/linux.sh" ] && . "$HOME/.config/shell/os/linux.sh"
  [ -n "$ID" ] && [ -r "$HOME/.config/shell/os/$ID.sh" ] && . "$HOME/.config/shell/os/$ID.sh"
else
  case "$(uname -s)" in
    Darwin) [ -r "$HOME/.config/shell/os/darwin.sh" ] && . "$HOME/.config/shell/os/darwin.sh" ;;
    Linux)  [ -r "$HOME/.config/shell/os/linux.sh" ]  && . "$HOME/.config/shell/os/linux.sh"  ;;
  esac
fi

# 3) hand off to your existing zsh config
[ -r "$HOME/.config/zsh/.zshrc" ] && . "$HOME/.config/zsh/.zshrc"
