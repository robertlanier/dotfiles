# shellcheck shell=bash
# Fedora-specific overlay (builds on linux.sh)

# Flatpak user and system export paths
[ -d "/var/lib/flatpak/exports/bin" ] \
    && case ":$PATH:" in *":/var/lib/flatpak/exports/bin:"*) ;; *) PATH="$PATH:/var/lib/flatpak/exports/bin" ;; esac

[ -d "$HOME/.local/share/flatpak/exports/bin" ] \
    && case ":$PATH:" in *":$HOME/.local/share/flatpak/exports/bin:"*) ;; *) PATH="$PATH:$HOME/.local/share/flatpak/exports/bin" ;; esac
