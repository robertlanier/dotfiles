# Catppuccin Macchiato theme for ble.sh
# Safe no-op if ble.sh is not loaded yet.

command -v ble-face >/dev/null 2>&1 || return 0 2>/dev/null || exit 0

# Core editor and completion colors (approximate Catppuccin Macchiato palette).
ble-face -s syntax_default              fg=250,bg=235 2>/dev/null || true
ble-face -s command_builtin             fg=117         2>/dev/null || true
ble-face -s command_function            fg=153         2>/dev/null || true
ble-face -s command_file                fg=111         2>/dev/null || true
ble-face -s command_keyword             fg=211         2>/dev/null || true
ble-face -s syntax_varname              fg=183         2>/dev/null || true
ble-face -s syntax_quot                 fg=186         2>/dev/null || true
ble-face -s syntax_error                fg=203,bold    2>/dev/null || true
ble-face -s region                      fg=250,bg=239 2>/dev/null || true
ble-face -s disabled                    fg=244         2>/dev/null || true
