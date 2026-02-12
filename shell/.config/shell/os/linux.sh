# Base Linux configuration - shared by all Linux distributions
# Linux specific environment
export BROWSER="${BROWSER:-firefox}"

# Add common Linux paths (with deduplication)
for p in /usr/local/sbin /usr/sbin /sbin /usr/local/bin /usr/bin /bin; do
    case ":$PATH:" in *":$p:"*) ;; *) [ -d "$p" ] && PATH="$p:$PATH" ;; esac
done

# Common Linux tools and settings
export HISTCONTROL=ignoreboth # Don't save duplicates or lines starting with space
export HISTSIZE=10000
export HISTFILESIZE=20000

# Set default pager
export PAGER="${PAGER:-less}"
export LESS="-R" # Raw color codes
