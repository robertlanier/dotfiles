# Ubuntu/Debian specific configuration
# Package management aliases
alias apt-update='sudo apt update && sudo apt upgrade'
alias apt-search='apt search'
alias apt-install='sudo apt install'

# Ubuntu specific paths and environment
[ -d "/snap/bin" ] && export PATH="/snap/bin:$PATH"

# WSL detection and setup
if grep -qi microsoft /proc/version 2>/dev/null; then
    # Running under WSL
    export WSL=1
    # WSL specific configurations can go here
fi