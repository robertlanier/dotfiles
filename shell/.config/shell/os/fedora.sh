# Fedora specific overlay (builds on linux.sh)
# Fedora uses dnf and has more modern defaults
alias pkg-update='sudo dnf update'
alias pkg-search='dnf search'  
alias pkg-install='sudo dnf install'
alias pkg-remove='sudo dnf remove'
alias pkg-info='dnf info'
alias pkg-upgrade='sudo dnf upgrade'

# Fedora Flatpak integration
command -v flatpak >/dev/null 2>&1 && alias flatpak-update='flatpak update'

# Fedora toolbox aliases if available
command -v toolbox >/dev/null 2>&1 && alias tb='toolbox'