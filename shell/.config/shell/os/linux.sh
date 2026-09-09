# shellcheck shell=bash
# Base Linux configuration - shared by all Linux distributions
# Linux specific environment
export BROWSER="${BROWSER:-firefox}"

# Add common Linux paths (with deduplication)
for p in /usr/local/bin /usr/bin /bin /usr/local/sbin /usr/sbin /sbin; do
    case ":$PATH:" in *":$p:"*) ;; *) [ -d "$p" ] && PATH="$PATH:$p" ;; esac
done

# bash-only history settings — zsh uses SAVEHIST and its own setopt flags
if [ -n "$BASH_VERSION" ]; then
    HISTCONTROL=ignoreboth
    HISTSIZE=10000
    HISTFILESIZE=20000
fi

# Set default pager
export PAGER="${PAGER:-less}"
export LESS="-R"

# SSH agent auto-start — Linux only (macOS manages this via launchd/Keychain)
if command -v ssh-agent >/dev/null 2>&1 && command -v ssh-add >/dev/null 2>&1; then
    if [ -z "$SSH_AUTH_SOCK" ] || ! ssh-add -l >/dev/null 2>&1; then
        SSH_ENV="${XDG_RUNTIME_DIR:-$HOME/.local/state}/ssh-agent.env"
        # Reuse a previously started agent if the env file exists
        if [ -f "$SSH_ENV" ]; then
            # shellcheck source=/dev/null
            . "$SSH_ENV" >/dev/null
        fi
        # Start a new agent if still not running, bound to a fixed socket path
        # so non-interactive processes (editors, scripts, services) can find it reliably
        if [ -z "$SSH_AUTH_SOCK" ] || ! ssh-add -l >/dev/null 2>&1; then
            SSH_SOCK="${XDG_RUNTIME_DIR:-$HOME/.local/state}/ssh-agent.socket"
            rm -f "$SSH_SOCK"
            ssh-agent -a "$SSH_SOCK" -s >"$SSH_ENV"
            # shellcheck source=/dev/null
            . "$SSH_ENV" >/dev/null
        fi
        # Load all private keys from ~/.ssh (detected by content, not extension)
        if [ -d "$HOME/.ssh" ]; then
            for key in "$HOME/.ssh/"*; do
                case "$key" in
                    *.pub | *.crt | *.pem | *.txt) continue ;;
                esac
                if grep -q 'PRIVATE KEY' "$key" 2>/dev/null; then
                    ssh-add "$key" 2>/dev/null
                fi
            done
        fi
    fi
fi
