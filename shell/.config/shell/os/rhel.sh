# RHEL/CentOS/Fedora specific configuration  
# Package management aliases
if command -v dnf >/dev/null 2>&1; then
    alias pkg-update='sudo dnf update'
    alias pkg-search='dnf search'  
    alias pkg-install='sudo dnf install'
elif command -v yum >/dev/null 2>&1; then
    alias pkg-update='sudo yum update'
    alias pkg-search='yum search'
    alias pkg-install='sudo yum install'  
fi

# RHEL specific environment
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH"

# Enterprise environment common settings
export HISTSIZE=10000
export HISTFILESIZE=20000