# shellcheck shell=bash
# WSL (Windows Subsystem for Linux) specific overlay
# This loads after the base Linux config and distribution overlay
if grep -qEi "(Microsoft|WSL)" /proc/version 2>/dev/null; then
    export WSL=1

    # Detect WSL 1 vs WSL 2
    if grep -qEi "WSL2" /proc/version 2>/dev/null; then
        export WSL_VERSION=2
    else
        export WSL_VERSION=1
    fi

    # Windows interop — add Windows paths (WSL2 injects them automatically; guard avoids duplication)
    for _wp in /mnt/c/Windows/System32 /mnt/c/Windows; do
        case ":$PATH:" in *":$_wp:"*) ;; *) PATH="$PATH:$_wp" ;; esac
    done
    unset _wp

    # Browser integration
    # Prefer wslview (wslu) if available; fall back to explorer.exe.
    # Note: Fedora's xdg-open has native WSL support and uses explorer.exe automatically,
    # so wslu is optional. Build from source: https://github.com/wslutilities/wslu
    if command -v wslview >/dev/null 2>&1; then
        export BROWSER="wslview"
    else
        export BROWSER="explorer.exe"
    fi

    # Clipboard integration
    if command -v clip.exe >/dev/null 2>&1; then
        alias pbcopy='clip.exe'
    fi

    if command -v powershell.exe >/dev/null 2>&1; then
        alias pbpaste='powershell.exe Get-Clipboard'
    fi

    # Disable bell in WSL 1 — `set bell-style none` is a readline directive, not a shell builtin;
    # use the shell-appropriate API so positional params are not clobbered.
    if [ "$WSL_VERSION" = "1" ]; then
        if [ -n "$BASH_VERSION" ]; then
            bind 'set bell-style none' 2>/dev/null || true
        elif [ -n "$ZSH_VERSION" ]; then
            unsetopt BEEP 2>/dev/null || true
        fi
    fi
fi
