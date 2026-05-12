# Bash profile (login shell configuration)
# Mirrors zsh/.config/zsh/.zprofile — ensures Homebrew is on PATH before .bashrc runs.

# Apple Silicon
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
# Intel Mac / Linuxbrew
[ -x /usr/local/bin/brew ] && eval "$(/usr/local/bin/brew shellenv)"
