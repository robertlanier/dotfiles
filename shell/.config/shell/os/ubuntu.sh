# shellcheck shell=bash
# Ubuntu/Debian specific overlay (builds on linux.sh)
# Ubuntu specific paths
[ -d "/snap/bin" ] && case ":$PATH:" in *":/snap/bin:"*) ;; *) PATH="/snap/bin:$PATH" ;; esac
