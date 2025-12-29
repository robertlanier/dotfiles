# 🧩 Dotfiles

Personal configuration files managed with **GNU Stow** for macOS (Apple Silicon), Linux (Ubuntu, RHEL, Fedora), and Windows via WSL.  
Everything is modular and lives inside `~/.config`, with small dispatcher files in `~` to make cross-platform setup effortless.

**✨ Features:**
- 🔄 **Automatic OS detection** - configs adapt to macOS, Ubuntu, RHEL, Fedora, WSL automatically
- 📦 **Modular packages** - install only what you need with stow
- 🏗️ **Base + overlay architecture** - shared Linux configs with distribution-specific overlays
- 🪟 **WSL support** - Windows integration via clipboard and browser
- 🚀 **Dual-remote push** - sync to both GitLab and GitHub with different emails

---

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
├─ starship/.config/starship/     # Starship prompt configuration
├─ vim/.config/vim/               # Vim configuration
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
- [Neovim](https://neovim.io/) - Modern vim (optional, falls back to vim)
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

# Install shell configuration (includes OS detection)
stow shell

# Install other packages as needed
stow zsh git vim starship fzf

# Reload your shell or start a new terminal session
exec $SHELL
```

### Windows (via WSL)

```powershell
# In PowerShell - Install WSL if not already installed
wsl --install

# Then follow the Linux/WSL instructions above inside WSL
```

**That's it!** The shell configuration will automatically detect your OS and load the appropriate configurations.

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

- **`shell`** - Cross-platform shell configuration with OS detection
- **`zsh`** - Zsh-specific configuration and plugins  
- **`git`** - Git configuration and aliases
- **`vim`** - Vim configuration
- **`starship`** - Cross-shell prompt configuration
- **`fzf`** - Fuzzy finder configuration

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

This dotfiles setup follows a **base + overlay** pattern:

- **Cross-platform base**: `common.sh` for universal settings
- **OS base**: `darwin.sh` (macOS) or `linux.sh` (Linux base)  
- **Distribution overlay**: `ubuntu.sh`, `fedora.sh`, etc. for specific additions
- **Thin dispatchers**: Small files in `~` that source the real configs in `~/.config`

This architecture provides:
- ✅ **No duplication** - shared configs in base files
- ✅ **Easy maintenance** - change base behavior in one place
- ✅ **Clean separation** - OS-specific code isolated
- ✅ **Extensible** - easy to add new distributions
