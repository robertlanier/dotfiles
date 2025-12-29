# 🧩 Dotfiles

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Platform: macOS | Linux | WSL](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20WSL-green.svg)](https://github.com/robertlanier/dotfiles)
[![Shell: Bash | Zsh](https://img.shields.io/badge/Shell-Bash%20%7C%20Zsh-informational.svg)](https://github.com/robertlanier/dotfiles)

> **Personal configuration files managed with GNU Stow for cross-platform development**

Modern, modular dotfiles with automatic OS detection, base + overlay architecture, and support for macOS, Linux distributions, and WSL. Everything lives in `~/.config` with thin dispatchers in `~` for effortless cross-platform setup.

---

## ✨ Features

- 🔄 **Automatic OS detection** - configs adapt to macOS, Ubuntu, RHEL, Fedora, WSL automatically
- 📦 **Modular packages** - install only what you need with stow
- 🏗️ **Base + overlay architecture** - shared Linux configs with distribution-specific overlays
- 🪟 **WSL support** - Windows integration via clipboard and browser
- 🚀 **Dual-remote push** - sync to both GitLab and GitHub with different emails
- 💾 **Backup & restore** - automatic backups with one-command rollback
- 🎯 **Zero manual config** - automated dependency installation

---

## 📋 Table of Contents

- [Features](#-features)
- [Requirements](#️-requirements)
- [Quick Start](#-quick-start)
- [Directory Structure](#-directory-structure)
- [OS Detection](#-how-os-detection-works)
- [Available Packages](#-available-packages)
- [Development](#-development--maintenance)
- [Architecture](#️-architecture)
- [Contributing](#-contributing)
- [License](#-license)

## 📁 Directory Structure

```
dotfiles/
├─ shell/                           # Cross-platform shared shell configuration
│  └─ .config/shell/
│     ├─ common.sh                 # Cross-platform shared config
│     └─ os/                       # OS-specific configurations
│        ├─ darwin.sh              # macOS (Homebrew, macOS aliases)
│        ├─ linux.sh               # Base Linux (all distributions)
│        ├─ ubuntu.sh              # Ubuntu/Debian overlay
│        ├─ fedora.sh              # Fedora overlay  
│        ├─ rhel.sh                # RHEL/CentOS overlay
│        └─ wsl.sh                 # WSL overlay (Windows integration)
│
├─ bash/                           # Bash-specific configuration
│  ├─ .bashrc → ~/.bashrc         # Bash dispatcher with OS detection
│  ├─ .bash_profile → ~/.bash_profile  # Bash login shell dispatcher
│  └─ .config/bash/
│     ├─ .bashrc                   # Main bash configuration
│     └─ .bash_profile             # Bash login shell setup
│
├─ zsh/                            # Zsh-specific configuration
│  ├─ .zshrc → ~/.zshrc           # Zsh dispatcher with OS detection
│  ├─ .zprofile → ~/.zprofile     # Zsh login shell dispatcher
│  └─ .config/zsh/
│     ├─ .zshrc                    # Main zsh configuration
│     ├─ .zprofile                 # Homebrew shellenv setup
│     ├─ plugins/                  # Zsh plugins (fzf-tab, autosuggestions)
│     ├─ cheatsheets/              # Command cheatsheets
│     └─ sessions/                 # Session state (gitignored)
│
├─ fzf/.config/fzf/               # Fuzzy finder configuration
├─ git/.config/git/               # Git configuration
├─ nvim/.config/nvim/             # Neovim configuration
├─ starship/.config/starship/     # Starship prompt configuration
├─ push-both.sh                   # Dual-remote push script
├─ .stow-local-ignore             # Files to exclude from stow
└─ .gitignore                     # Git ignore rules
```

---

## ⚙️ Requirements

**The `install.sh` script will automatically install these for you!** 

Manual installation requirements:

- [Git](https://git-scm.com/)
- [GNU Stow](https://www.gnu.org/software/stow/)
- [Starship](https://starship.rs/) - Cross-shell prompt
- [Zoxide](https://github.com/ajeetdsouza/zoxide) - Smart cd replacement  
- [FZF](https://github.com/junegunn/fzf) - Fuzzy finder
- [Neovim](https://neovim.io/) - Modern text editor
- [Fastfetch](https://github.com/fastfetch-cli/fastfetch) - System info (optional)
- (macOS) [Homebrew](https://brew.sh/) - Package manager

### Manual Stow Installation (if needed)
```bash
# macOS
brew install stow

# Debian / Ubuntu
sudo apt install stow

# RHEL / CentOS / Fedora
sudo dnf install stow

# Arch Linux
sudo pacman -S stow
```

---

## 🚀 Quick Start

### Automated Installation (Recommended)

```bash
# Clone and deploy in one command
git clone https://github.com/robertlanier/dotfiles.git
cd dotfiles
./install.sh

# Reload your shell
exec $SHELL
```

**What this does:**
- ✅ Installs all required tools (starship, zoxide, fzf, neovim, etc.)
- ✅ Creates timestamped backup of existing configs  
- ✅ Deploys dotfiles using stow
- ✅ Creates restore script for easy rollback
- ✅ Verifies installation

### Installation Options

```bash
# Full installation (default)
./install.sh

# Install dependencies only (no config changes)  
./install.sh --deps-only

# Skip backup (if you're confident)
./install.sh --skip-backup

# Install deps and backup, but don't deploy configs
./install.sh --skip-deploy
```

### Manual Installation

#### macOS / Linux / WSL

```bash
# Clone the repository
git clone https://github.com/robertlanier/dotfiles.git
cd dotfiles

# Install requirements manually (see Requirements section below)

# Install shell configuration (shared configs)
stow shell

# Install shell-specific packages
stow bash zsh

# Install other packages as needed
stow git nvim starship fzf

# Reload your shell or start a new terminal session
exec $SHELL
```

### Windows (via WSL)

```powershell
# In PowerShell - Install WSL if not already installed
wsl --install

# Then follow the Linux/WSL instructions above inside WSL
```

**That's it!** The bash and zsh dispatchers will automatically detect your OS and load the appropriate configurations from `~/.config/shell/`.

> **Note:** Native Windows (PowerShell/CMD) is not supported. Use WSL for Windows environments.

### 🔄 Rollback & Uninstallation

If you need to revert your dotfiles installation:

```bash
# Use the automatically created restore script
~/.dotfiles-backup-YYYYMMDD-HHMMSS/restore.sh

# Or use the uninstall script (interactive backup selection)
./uninstall.sh

# Auto-select most recent backup
./uninstall.sh --auto

# Use specific backup
./uninstall.sh --backup ~/.dotfiles-backup-20241114-143022
```

**Restore features:**
- ✅ Automatically removes dotfiles symlinks
- ✅ Restores all original config files
- ✅ Interactive backup selection
- ✅ Complete rollback in seconds

---

## 🔄 How OS Detection Works

The shell configuration automatically detects your operating system and loads the appropriate settings:

### **macOS (Darwin)**
- Loads: `common.sh` → `darwin.sh`
- Includes: Homebrew setup, macOS-specific aliases, BSD command variants

### **Linux Distributions**  

- Loads: `common.sh` → `linux.sh` → `{distribution}.sh` → `wsl.sh` (if in WSL)
- **Ubuntu/Debian**: Adds `apt` aliases, snap paths
- **RHEL/CentOS**: Adds `yum`/`dnf` aliases, SELinux helpers, enterprise settings
- **Fedora**: Adds modern `dnf` commands, Flatpak integration, toolbox support
- **WSL**: Adds Windows clipboard integration (`pbcopy`/`pbpaste`), browser integration

### **Supported Platforms**

- ✅ macOS (Apple Silicon & Intel)
- ✅ Ubuntu / Debian
- ✅ RHEL / CentOS / Rocky Linux
- ✅ Fedora
- ✅ WSL (Windows Subsystem for Linux)
- ✅ Any Linux distribution (falls back to base `linux.sh`)
- ❌ Native Windows (PowerShell/CMD) - use WSL instead

---

## 📦 Available Packages

Each directory is a separate stow package that can be installed independently:

| Package | Description |
|---------|-------------|
| `shell` | Cross-platform shared shell configuration (common.sh, OS overlays) |
| `bash` | Bash-specific configuration and dispatchers |
| `zsh` | Zsh-specific configuration, plugins, and dispatchers |
| `git` | Git configuration and aliases |
| `nvim` | Neovim configuration |
| `starship` | Cross-shell prompt configuration |
| `fzf` | Fuzzy finder configuration |
| `vscode` | VS Code settings and extensions |

---

## 🔧 Development & Maintenance

### Dual Remote Setup
This repository pushes to both GitLab and GitHub with different commit emails:
- **GitLab**: `robert.lanier@phreesia.com`
- **GitHub**: `lanier@posteo.com`

```bash
# Push to both remotes simultaneously
./push-both.sh main

# Or push individually  
git push origin main    # GitLab
git push github main    # GitHub
```

### Adding New OS Support
To add support for a new Linux distribution:

1. Create `shell/.config/shell/os/{distro}.sh`
2. Add distribution-specific configurations
3. The OS detection will automatically load it based on `/etc/os-release`

---

## 🏗️ Architecture

This dotfiles setup follows a **base + overlay** pattern with **shell-specific packages**:

### Shared Configuration (`shell/`)
- **Cross-platform base**: `common.sh` for universal settings
- **OS base**: `darwin.sh` (macOS) or `linux.sh` (Linux base)  
- **Distribution overlay**: `ubuntu.sh`, `fedora.sh`, etc. for specific additions

### Shell Packages (`bash/`, `zsh/`)
- **Thin dispatchers**: Small files in `~` (`.bashrc`, `.zshrc`) that detect OS and source shared configs
- **Shell-specific configs**: Each shell has its own `.config/{bash,zsh}/` for shell-specific features

### Benefits
- ✅ **No duplication** - shared configs in base files, shell-specific logic isolated
- ✅ **Easy maintenance** - change base behavior once in `shell/`, affects all shells
- ✅ **Clean separation** - OS-specific code in overlays, shell-specific code in packages
- ✅ **Extensible** - easy to add new distributions or shells

---

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Quick Contribution Guide

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'feat: add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines on code style, testing, and commit conventions.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [GNU Stow](https://www.gnu.org/software/stow/) - Symlink farm manager
- [Starship](https://starship.rs/) - Cross-shell prompt
- [Catppuccin](https://github.com/catppuccin) - Soothing pastel theme
- [fzf-tab](https://github.com/Aloxaf/fzf-tab) - Zsh tab completion with fzf

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/robertlanier">Robert LaNier</a>
</p>
