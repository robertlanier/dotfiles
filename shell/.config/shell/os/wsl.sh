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
	
	# --- Use Windows OpenSSH tools ---
    alias ssh='/mnt/c/Windows/System32/OpenSSH/ssh.exe'
    alias scp='/mnt/c/Windows/System32/OpenSSH/scp.exe'
    alias sftp='/mnt/c/Windows/System32/OpenSSH/sftp.exe'
    alias ssh-add='/mnt/c/Windows/System32/OpenSSH/ssh-add.exe'

    # Use Windows SSH for Git too
    git config --global core.sshCommand '/mnt/c/Windows/System32/OpenSSH/ssh.exe'
    
    # Browser integration
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
    
    # Fix for WSL 1 interop issues
    if [ "$WSL_VERSION" = "1" ]; then
        # Disable bell in WSL 1 (can be annoying)
        set bell-style none 2>/dev/null || true
    fi
fi
