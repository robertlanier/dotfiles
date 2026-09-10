# Installation

## Quick Start

```bash
git clone https://github.com/robertlanier/dotfiles.git
cd dotfiles
git submodule update --init --recursive
./install.sh
exec $SHELL
```

## Options

| Flag | Description |
| ---- | ----------- |
| *(none)* | Full install: deps + backup + deploy |
| `--deps-only` | Install tools only, no config changes |
| `--skip-backup` | Skip backup and restore prompt |
| `--skip-deploy` | Install dependencies only — no backup, no stow |
| `--zsh` | Configure zsh as default shell (non-interactive) |
| `--no-zsh` | Skip zsh shell configuration |
| `-h, --help` | Show help |

## What install.sh Does

1. Detects OS and package manager
2. Installs all tools (see Brewfile on macOS; individual installers on Linux)
3. Prompts to configure zsh as default shell
4. Backs up any existing non-symlinked config files to `~/.dotfiles-backup-<timestamp>`
5. Runs `stow -R` for all packages — safe to re-run on an already-deployed machine
6. Creates `~/.tmux.conf` symlink to oh-my-tmux, installs TPM and plugins
7. Installs CaskaydiaCove Nerd Font (macOS) or JetBrains Mono Nerd Font (Linux)
8. Installs lefthook git hooks
9. Rebuilds bat cache

## Re-running on an Existing Deployment

`install.sh` detects whether dotfiles are already active by checking if `~/.bashrc` is a symlink into the repo. In **update mode**:

- The restore-from-backup prompt is skipped
- `stow -R` picks up any new or removed files in packages
- All tool installs are idempotent (already-present tools are skipped)

## Stow Packages

| Package | Manages |
| ------- | ------- |
| `shell` | `~/.config/shell/` — common.sh and OS overlays |
| `bash` | `~/.bashrc`, `~/.config/bash/` |
| `zsh` | `~/.zshrc`, `~/.config/zsh/` + plugin submodules |
| `git` | `~/.gitconfig`, `~/.gitignore_global`, `~/.catppuccin.gitconfig` |
| `nvim` | `~/.config/nvim/` |
| `starship` | `~/.config/starship.toml` |
| `fzf` | `~/.config/fzf/` |
| `bat` | `~/.config/bat/` |
| `tmux` | `~/.tmux.conf.local` |

Deploy all: `stow shell bash zsh git starship fzf nvim bat tmux`

## Machine-Local Config

Create `~/.config/shell/local.sh` for anything not tracked in the repo (work aliases, private tokens, machine-specific PATH entries). This file is sourced last by both dispatchers — it always wins over OS overlays.

## Manual Stow (no install.sh)

```bash
# Backup existing configs first, then:
stow shell bash zsh git starship fzf nvim bat tmux

# Verify with dry-run before deploying
stow -nv shell
```
