# Uninstalling

## Quick Uninstall

```bash
./uninstall.sh
```

Snapshots the current live config, removes stow symlinks, prompts to select a backup to restore from.

## Options

| Flag | Description |
| ---- | ----------- |
| `--auto` | Auto-select the most recent backup |
| `--backup DIR` | Restore from a specific backup directory |
| `--skip-plugins` | Skip removing TPM plugins and `~/.local/bin/` binaries |
| `--skip-snapshot` | Skip pre-uninstall config snapshot |
| `-h, --help` | Show help |

## What Gets Removed

- All stow-managed symlinks (`~/.bashrc`, `~/.zshrc`, `~/.gitconfig`, etc.)
- `~/.tmux.conf` symlink
- `~/.tmux/plugins/` (TPM and all installed plugins)
- Catppuccin tmux plugin (if from old manual install)
- `~/.local/bin/` binaries installed by `install.sh`: shfmt, lefthook, git-cliff, yq, glab, eza
- JetBrains Mono Nerd Font (`~/.local/share/fonts/JetBrainsMono/`)

**Not removed:** tools installed via apt/dnf/brew, macOS Homebrew fonts.

## Backup and Restore

`install.sh` creates `~/.dotfiles-backup-<timestamp>/` before deploying. `uninstall.sh` lets you restore from any of these backups.

`uninstall.sh` also creates a `~/.dotfiles-snapshot-<timestamp>/` immediately before removing symlinks, capturing the current live state (symlinks dereferenced with `cp -rL`).

If the interactive restore prompt is broken or you need to restore manually:

```bash
cp -rL ~/.dotfiles-backup-<timestamp>/. ~/
```
