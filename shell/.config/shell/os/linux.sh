# Base Linux configuration - shared by all Linux distributions
# Common Linux aliases
alias ls='ls --color=auto'
alias ll='ls -l --color=auto'
alias la='ls -la --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Linux specific environment
export BROWSER="${BROWSER:-firefox}"

# Add common Linux paths
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH"

# Common Linux tools and settings
export HISTCONTROL=ignoreboth  # Don't save duplicates or lines starting with space
export HISTSIZE=10000
export HISTFILESIZE=20000

# Set default pager
export PAGER="${PAGER:-less}"
export LESS="-R"  # Raw color codes