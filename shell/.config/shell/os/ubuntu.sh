# Ubuntu/Debian specific overlay (builds on linux.sh)
# Package management aliases
alias apt-update='sudo apt update && sudo apt upgrade'
alias apt-search='apt search'
alias apt-install='sudo apt install'
alias apt-remove='sudo apt remove'
alias apt-autoremove='sudo apt autoremove'

# Ubuntu specific paths
[ -d "/snap/bin" ] && export PATH="/snap/bin:$PATH"