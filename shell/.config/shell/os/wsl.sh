# WSL (Windows Subsystem for Linux) specific overlay
# This loads after the base Linux config and distribution overlay

# Detect WSL version
if grep -qEi "(Microsoft|WSL)" /proc/version 2>/dev/null; then
    export WSL=1
    
    # Detect WSL 1 vs WSL 2
    if grep -qEi "WSL2" /proc/version 2>/dev/null; then
        export WSL_VERSION=2
    else
        export WSL_VERSION=1
    fi
    
    # Windows interop - add Windows paths
    export PATH="$PATH:/mnt/c/Windows/System32:/mnt/c/Windows"
    
    # Browser integration
    if command -v wslview >/dev/null 2>&1; then
        export BROWSER="wslview"
    else
        export BROWSER="explorer.exe"
    fi
    
    # Windows tools aliases
    alias cmd='cmd.exe'
    alias powershell='powershell.exe'
    alias pwsh='pwsh.exe'
    alias explorer='explorer.exe'
    alias notepad='notepad.exe'
    
    # Clipboard integration
    if command -v clip.exe >/dev/null 2>&1; then
        alias pbcopy='clip.exe'
        alias clipboard='clip.exe'
    fi
    
    if command -v powershell.exe >/dev/null 2>&1; then
        alias pbpaste='powershell.exe Get-Clipboard'
    fi
    
    # Docker Desktop integration (if using Docker Desktop for Windows)
    if [ -S "/mnt/wsl/shared-docker/docker.sock" ]; then
        export DOCKER_HOST="unix:///mnt/wsl/shared-docker/docker.sock"
    fi
    
    # Fix for WSL 1 interop issues
    if [ "$WSL_VERSION" = "1" ]; then
        # Disable bell in WSL 1 (can be annoying)
        set bell-style none 2>/dev/null || true
    fi
    
    # Better file permissions for WSL (optional, uncomment if needed)
    # umask 022
    
    # Windows home directory shortcut
    if [ -d "/mnt/c/Users" ]; then
        export WINHOME="/mnt/c/Users/$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')"
        alias winhome='cd "$WINHOME"'
        alias windocs='cd "$WINHOME/Documents"'
        alias windown='cd "$WINHOME/Downloads"'
        alias windesk='cd "$WINHOME/Desktop"'
    fi
    
    # VSCode integration (if using VSCode on Windows)
    if command -v code.exe >/dev/null 2>&1; then
        alias code='code.exe'
    fi
fi