# Base Linux configuration - shared by all Linux distributions
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
