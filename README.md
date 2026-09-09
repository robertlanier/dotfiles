# Dotfiles

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Platform: macOS | Linux | WSL](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20WSL-green.svg)](https://github.com/robertlanier/dotfiles)
[![Shell: Bash | Zsh](https://img.shields.io/badge/Shell-Bash%20%7C%20Zsh-informational.svg)](https://github.com/robertlanier/dotfiles)

Personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/). Supports macOS, Ubuntu, RHEL, Fedora, and WSL with automatic OS detection, a base + overlay shell architecture, and a single `install.sh` that handles everything.

## Quick Start

```bash
git clone https://github.com/robertlanier/dotfiles.git
cd dotfiles
git submodule update --init --recursive
./install.sh
exec $SHELL
```

See [docs/install.md](docs/install.md) for all options and what `install.sh` does.

## Documentation

| Doc | Description |
| --- | ----------- |
| [docs/install.md](docs/install.md) | Installation options, stow packages, re-run behavior |
| [docs/update.md](docs/update.md) | Updating tools, submodules, and plugins |
| [docs/uninstall.md](docs/uninstall.md) | Uninstalling and restoring from backup |
| [docs/hooks.md](docs/hooks.md) | Git hooks via Lefthook (shellcheck, shfmt) |
| [docs/dependencies.md](docs/dependencies.md) | Submodules, TPM, fonts, and Brewfile maintenance |
| [docs/commands.md](docs/commands.md) | Quick reference for all commands |

## Platforms

- macOS (Apple Silicon & Intel)
- Ubuntu / Debian
- RHEL / CentOS / Rocky Linux / AlmaLinux
- Fedora
- WSL (Windows Subsystem for Linux)

> Native Windows (PowerShell/CMD) is not supported. Use WSL.

## License

MIT — see [LICENSE](LICENSE).

## Acknowledgments

[GNU Stow](https://www.gnu.org/software/stow/) · [Starship](https://starship.rs/) · [Catppuccin](https://github.com/catppuccin) · [oh-my-tmux](https://github.com/gpakosz/.tmux) · [fzf-tab](https://github.com/Aloxaf/fzf-tab)
