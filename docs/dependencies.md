# Managed Dependencies

Components that require maintenance beyond standard stow — submodules, plugin managers, and externally downloaded assets.

---

## Git Submodules

Three submodules are tracked in `.gitmodules`. All are populated by `git submodule update --init --recursive` (run by `install.sh` and required after clone).

### oh-my-tmux

| | |
|---|---|
| **Submodule path** | `tmux-ohmytmux/` |
| **Upstream** | https://github.com/gpakosz/.tmux |
| **Deployed as** | `~/.tmux.conf` → absolute symlink to `tmux-ohmytmux/.tmux.conf` (created by `install.sh`, not stow) |
| **User config** | `~/.tmux.conf.local` (stow `tmux` package → `tmux/.tmux.conf.local`) |

oh-my-tmux initializes TPM at the end of its own `.tmux.conf`. Do **not** add a `run` line to `.tmux.conf.local`.

**Install:** `install.sh` creates the `~/.tmux.conf` symlink and clones TPM.

**Update:**
```bash
./update.sh submodules          # updates oh-my-tmux to latest upstream commit
git submodule update --remote tmux-ohmytmux   # targeted update
```

**Uninstall:** `uninstall.sh` removes `~/.tmux.conf` and `~/.tmux/plugins/`.

---

### fzf-tab

| | |
|---|---|
| **Submodule path** | `zsh/.config/zsh/plugins/fzf-tab/` |
| **Upstream** | https://github.com/Aloxaf/fzf-tab |
| **Deployed as** | stow `zsh` package → `~/.config/zsh/plugins/fzf-tab/` |

Must be sourced **after** `compinit` and **before** `zsh-autosuggestions` and `fast-syntax-highlighting`. See zsh plugin ordering in `AGENTS.md`.

**Update:**
```bash
./update.sh submodules
git submodule update --remote zsh/.config/zsh/plugins/fzf-tab
```

---

### zsh-fsh (Catppuccin fast-syntax-highlighting)

| | |
|---|---|
| **Submodule path** | `zsh/.config/zsh/plugins/zsh-fsh/` |
| **Upstream** | https://github.com/catppuccin/zsh-fsh |
| **Deployed as** | stow `zsh` package → `~/.config/zsh/plugins/zsh-fsh/` |

Provides the Catppuccin Macchiato theme for fast-syntax-highlighting. Must be sourced **last** of all zsh plugins.

**Update:**
```bash
./update.sh submodules
git submodule update --remote zsh/.config/zsh/plugins/zsh-fsh
```

---

## TPM (Tmux Plugin Manager)

| | |
|---|---|
| **Location** | `~/.tmux/plugins/tpm/` |
| **Source** | https://github.com/tmux-plugins/tpm |
| **Managed by** | `install.sh` (cloned); TPM itself manages all plugin subdirectories |

TPM is **not** a git submodule — it is cloned fresh by `install.sh` to `~/.tmux/plugins/tpm/`.

### TPM Plugins

Declared in `tmux/.tmux.conf.local`:

| Plugin | Purpose |
| ------ | ------- |
| `catppuccin/tmux` | Catppuccin Macchiato status bar theme |
| `tmux-plugins/tmux-resurrect` | Save and restore sessions across restarts |
| `tmux-plugins/tmux-continuum` | Auto-save every 15 min; restore on server start |
| `tmux-plugins/tmux-yank` | System clipboard integration in copy mode |
| `jaclu/tmux-menus` | Context menus via popup |
| `tmux-plugins/tmux-cpu` | CPU usage in status bar |
| `tmux-plugins/tmux-battery` | Battery percentage in status bar |

**Install plugins (CLI):**
```bash
~/.tmux/plugins/tpm/bin/install_plugins
```

**Update plugins:**
```bash
./update.sh tpm
# or
~/.tmux/plugins/tpm/bin/update_plugins all
```

**Inside tmux** (prefix = `ctrl-a`):

| Keys | Action |
| ---- | ------ |
| `prefix I` | Install new plugins |
| `prefix U` | Update installed plugins |
| `prefix r` | Reload config |
| `prefix e` | Edit `~/.tmux.conf.local` |
| `prefix m` | Toggle mouse |

**Uninstall:** `uninstall.sh` removes `~/.tmux/plugins/` entirely.

---

## Nerd Fonts

### macOS — CaskaydiaCove Nerd Font (NF)

| | |
|---|---|
| **Managed by** | Homebrew — `Brewfile` cask `font-caskaydia-cove-nerd-font` |
| **Install** | `brew bundle` (run by `install.sh`) |
| **Update** | `./update.sh homebrew` |
| **Terminal font name** | `CaskaydiaCove Nerd Font` |

### Linux — JetBrains Mono Nerd Font (NF)

| | |
|---|---|
| **Location** | `~/.local/share/fonts/JetBrainsMono/` |
| **Source** | https://github.com/ryanoasis/nerd-fonts releases — `JetBrainsMono.tar.xz` |
| **Install** | `install.sh` → `install_nerd_font()` |
| **Update** | `./update.sh nerd-font` |
| **Cache refresh** | `fc-cache -fv` (run automatically by install and update) |
| **Terminal font name** | `JetBrainsMono Nerd Font` |

---

## Brewfile (macOS only)

| | |
|---|---|
| **Location** | `Brewfile` (repo root) |
| **Managed by** | `brew bundle` |
| **Install** | `install.sh` → `run_brew_bundle()` |
| **Update** | `./update.sh homebrew` runs `brew update && brew upgrade && brew bundle` |

All macOS tools, casks, and fonts are declared here. Adding a new macOS tool: add a `brew "name"` or `cask "name"` line to `Brewfile`.
