# RHEL/CentOS specific overlay (builds on linux.sh)
# Package management aliases - prefer dnf over yum
if command -v dnf >/dev/null 2>&1; then
    alias pkg-update='sudo dnf update'
    alias pkg-search='dnf search'  
    alias pkg-install='sudo dnf install'
    alias pkg-remove='sudo dnf remove'
    alias pkg-info='dnf info'
elif command -v yum >/dev/null 2>&1; then
    alias pkg-update='sudo yum update'
    alias pkg-search='yum search'
    alias pkg-install='sudo yum install'
    alias pkg-remove='sudo yum remove'
    alias pkg-info='yum info'
fi

# RHEL enterprise environment settings
export TMOUT=0  # Disable shell timeout (common in enterprise)

# SELinux helpers if available
command -v sestatus >/dev/null 2>&1 && alias selinux-status='sestatus'
command -v setsebool >/dev/null 2>&1 && alias selinux-bool='sudo setsebool'