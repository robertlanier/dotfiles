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

    # Windows interop — add Windows paths
    export PATH="$PATH:/mnt/c/Windows/System32:/mnt/c/Windows"

    # Browser integration
    # wslview (from wslu package) opens URLs in the default Windows browser.
    # Install on Fedora: sudo dnf copr enable wsl-utilities/wslu && sudo dnf install wslu
    if command -v wslview >/dev/null 2>&1; then
        export BROWSER="wslview"
    else
        export BROWSER="explorer.exe"
    fi

    # xdg-open: point to wslview so CLI tools (including op) can open Windows browser
    if command -v wslview >/dev/null 2>&1 && ! command -v xdg-open >/dev/null 2>&1; then
        alias xdg-open='wslview'
    fi

    # Clipboard integration
    if command -v clip.exe >/dev/null 2>&1; then
        alias pbcopy='clip.exe'
    fi

    if command -v powershell.exe >/dev/null 2>&1; then
        alias pbpaste='powershell.exe Get-Clipboard'
    fi

    # 1Password CLI integration
    # Connects `op` to the Windows 1Password desktop app over a Unix socket.
    #
    # Required Windows-side setup (do once):
    #   1Password > Settings > Developer > check "Connect with 1Password CLI"
    #   1Password > Settings > Developer > check "Use the SSH agent"
    #
    # The socket is created by the Windows app; try known locations in order.
    _op_sock_found=""
    for _op_sock in \
        "/mnt/c/Users/$(whoami)/AppData/Local/1Password/app/8/1Password.sock" \
        "$HOME/.1password/agent.sock"; do
        if [ -S "$_op_sock" ]; then
            _op_sock_found="$_op_sock"
            break
        fi
    done
    if [ -n "$_op_sock_found" ]; then
        export OP_AGENT_SOCK="$_op_sock_found"
    fi
    unset _op_sock _op_sock_found

    # Fix for WSL 1 interop issues
    if [ "$WSL_VERSION" = "1" ]; then
        # Disable bell in WSL 1 (can be annoying)
        set bell-style none 2>/dev/null || true
    fi
fi
