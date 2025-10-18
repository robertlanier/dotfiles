# Linux generic configuration
# Common Linux aliases
alias ls='ls --color=auto'
alias ll='ls -l --color=auto'
alias la='ls -la --color=auto'

# Linux specific environment
export BROWSER="${BROWSER:-firefox}"

# Add common Linux paths
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH"