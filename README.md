# 🧩 Dotfiles

Personal configuration files managed with **GNU Stow** for macOS (Apple Silicon) and Linux (Debian / RHEL).  
Everything is modular and lives inside `~/.config`, with small dispatcher files in `~` to make cross-platform setup effortless.

---

## 📁 Directory Structure

dotfiles/
├─ shell/ # Top-level shell configs
│ ├─ .zshrc → ~/.zshrc
│ ├─ .zprofile → ~/.zprofile
│ └─ .config/shell/
│ ├─ common.sh → ~/.config/shell/common.sh (shared env + aliases)
│
├─ zsh/
│ └─ .config/zsh/
│ ├─ .zshrc → ~/.config/zsh/.zshrc (main zsh config)
│ ├─ .zprofile → ~/.config/zsh/.zprofile (Homebrew shellenv)
│ ├─ plugins/ (fzf-tab, autosuggestions, etc.)
│ ├─ cheatsheets/
│ └─ sessions/ (ignored runtime state)
│
├─ fzf/.config/fzf/ → ~/.config/fzf
├─ git/.config/git/ → ~/.config/git
├─ starship/.config/starship/ → ~/.config/starship
├─ vim/.config/vim/ → ~/.config/vim
└─ .stow-local-ignore / .gitignore

---

## ⚙️ Requirements

- [Git](https://git-scm.com/)
- [GNU Stow](https://www.gnu.org/software/stow/)
- (macOS) [Homebrew](https://brew.sh/)

### Install Stow
```bash
# macOS
brew install stow

# Debian / Ubuntu
sudo apt install stow

# RHEL / Fedora
sudo dnf install stow
```