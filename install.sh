#!/bin/bash

# Dotfiles installation script
# Automatically installs requirements, backs up existing configs, and deploys dotfiles

set -e # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
PACKAGES_TO_STOW="shell bash zsh git starship fzf nvim bat tmux"
CONFIG_FILES=(
    ".zshrc"
    ".bashrc"
    ".bash_profile"
    ".zprofile"
    ".gitconfig"
    ".gitignore_global"
    ".catppuccin.gitconfig"
    ".config/starship.toml"
    ".config/nvim"
    ".config/zsh"
    ".config/bash"
    ".config/shell"
    ".config/fzf"
    ".config/bat"
    ".config/tmux"
)

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect OS and distribution
detect_os() {
    if [[ $OSTYPE == "darwin"* ]]; then
        OS="macos"
        log_info "Detected macOS"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS="linux"
        DISTRO="$ID"
        log_info "Detected Linux: $PRETTY_NAME"
    else
        log_error "Unsupported operating system"
        exit 1
    fi
}

# Install package manager tools
install_package_manager() {
    case "$OS-$DISTRO" in
        "linux-ubuntu" | "linux-debian")
            if ! command_exists apt; then
                log_error "apt package manager not found"
                exit 1
            fi
            log_info "Updating package lists..."
            sudo apt update
            ;;
        "linux-rhel" | "linux-centos" | "linux-rocky" | "linux-almalinux")
            if command_exists dnf; then
                PACKAGE_MANAGER="dnf"
            elif command_exists yum; then
                PACKAGE_MANAGER="yum"
            else
                log_error "No compatible package manager found (dnf/yum)"
                exit 1
            fi
            ;;
        "linux-fedora")
            if ! command_exists dnf; then
                log_error "dnf package manager not found"
                exit 1
            fi
            PACKAGE_MANAGER="dnf"
            ;;
        "macos"*)
            # Homebrew is installed by install_homebrew() via run_brew_bundle
            ;;
    esac
}

# Enable EPEL and CodeReady Linux Builder on RHEL-family distros
# Fedora has its own full package set and does not need EPEL
enable_epel() {
    case "$OS-$DISTRO" in
        "linux-rhel" | "linux-centos" | "linux-rocky" | "linux-almalinux") ;;
        *) return ;;
    esac

    if dnf repolist enabled 2>/dev/null | grep -q "^epel"; then
        log_success "EPEL already enabled"
        return
    fi

    log_info "Enabling EPEL and CodeReady Linux Builder..."
    sudo dnf install -y dnf-plugins-core

    case "$DISTRO" in
        rhel)
            # RHEL: epel-release is not in base repos — install directly from Fedora mirrors
            if ! sudo dnf install -y epel-release 2>/dev/null; then
                sudo dnf install -y \
                    "https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm"
            fi
            sudo subscription-manager repos \
                --enable "codeready-builder-for-rhel-9-$(uname -m)-rpms" 2>/dev/null \
                || log_warning "CRB not enabled via subscription-manager — some EPEL packages may be unavailable"
            ;;
        centos | rocky | almalinux)
            sudo dnf install -y epel-release
            sudo dnf config-manager --set-enabled crb 2>/dev/null \
                || sudo /usr/bin/crb enable 2>/dev/null \
                || log_warning "CRB not enabled — some EPEL packages may be unavailable"
            ;;
    esac

    log_success "EPEL enabled"
}

# Install Homebrew (macOS only)
install_homebrew() {
    if command_exists brew; then
        log_success "Homebrew already installed"
        return
    fi

    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    for brew_prefix in /opt/homebrew /usr/local; do
        if [ -x "${brew_prefix}/bin/brew" ]; then
            eval "$("${brew_prefix}/bin/brew" shellenv)"
            break
        fi
    done

    if ! command_exists brew; then
        log_error "Homebrew installation failed."
        exit 1
    fi

    log_success "Homebrew installed"
}

# Run brew bundle — macOS only; Linux uses native package managers
run_brew_bundle() {
    [ "$OS" != "macos" ] && return

    local brewfile="${SCRIPT_DIR}/Brewfile"

    if [ ! -f "$brewfile" ]; then
        log_warning "Brewfile not found at $brewfile — skipping brew bundle"
        return
    fi

    log_info "Checking Homebrew installation..."
    install_homebrew

    log_info "Verifying Homebrew is functional..."
    if ! brew --version >/dev/null 2>&1; then
        log_error "Homebrew is not functional. Cannot run brew bundle."
        exit 1
    fi
    log_success "Homebrew $(brew --version | head -1)"

    log_info "Running brew bundle..."
    brew bundle --file="$brewfile"
    log_success "brew bundle complete"
}

# Install core dependencies
install_core_deps() {
    # Skip if all core tools are already present
    if command_exists git && command_exists stow && command_exists zsh && command_exists curl; then
        log_success "Core dependencies already installed"
        return
    fi

    log_info "Installing core dependencies..."

    case "$OS-$DISTRO" in
        "linux-ubuntu" | "linux-debian")
            sudo apt install -y git stow zsh curl wget bash-completion
            ;;
        "linux-rhel" | "linux-centos" | "linux-rocky" | "linux-almalinux" | "linux-fedora")
            sudo "$PACKAGE_MANAGER" install -y git stow zsh curl wget bash-completion
            ;;
        "macos"*)
            # git, stow, and all tools are managed by the Brewfile — nothing to do here
            ;;
    esac
}

# Install starship prompt
# Not in Fedora or RHEL repos — use the official cross-platform installer
install_starship() {
    if command_exists starship; then
        log_success "Starship already installed"
        return
    fi

    log_info "Installing Starship prompt..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
}

# Install fastfetch
install_fastfetch() {
    if command_exists fastfetch; then
        log_success "Fastfetch already installed"
        return
    fi

    log_info "Installing Fastfetch..."
    case "$OS-$DISTRO" in
        "linux-ubuntu" | "linux-debian")
            if ! sudo apt install -y fastfetch 2>/dev/null; then
                log_warning "Fastfetch not available in repos, skipping..."
            fi
            ;;
        "linux-fedora")
            sudo dnf install -y fastfetch
            ;;
        "linux-rhel" | "linux-centos" | "linux-rocky" | "linux-almalinux")
            if ! sudo "$PACKAGE_MANAGER" install -y fastfetch 2>/dev/null; then
                log_warning "Fastfetch not available in repos, skipping..."
            fi
            ;;
    esac
}

# Install zoxide
install_zoxide() {
    if command_exists zoxide; then
        log_success "Zoxide already installed"
        return
    fi

    log_info "Installing Zoxide..."
    case "$OS-$DISTRO" in
        "linux-ubuntu" | "linux-debian")
            if ! sudo apt install -y zoxide 2>/dev/null; then
                curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
            fi
            ;;
        "linux-rhel" | "linux-centos" | "linux-rocky" | "linux-almalinux" | "linux-fedora")
            if ! sudo "$PACKAGE_MANAGER" install -y zoxide 2>/dev/null; then
                curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
            fi
            ;;
    esac
}

# Install fzf
install_fzf() {
    if command_exists fzf; then
        log_success "FZF already installed"
        return
    fi

    log_info "Installing FZF..."
    case "$OS-$DISTRO" in
        "linux-ubuntu" | "linux-debian")
            sudo apt install -y fzf
            ;;
        "linux-rhel" | "linux-centos" | "linux-rocky" | "linux-almalinux" | "linux-fedora")
            sudo "$PACKAGE_MANAGER" install -y fzf
            ;;
    esac
}

# Install ShellCheck (shell script linter)
install_shellcheck() {
    if command_exists shellcheck; then
        log_success "ShellCheck already installed"
        return
    fi

    log_info "Installing ShellCheck..."
    case "$OS-$DISTRO" in
        "linux-ubuntu" | "linux-debian")
            if ! sudo apt install -y shellcheck 2>/dev/null; then
                log_warning "ShellCheck not available in apt repos, install manually: https://github.com/koalaman/shellcheck#installing"
            fi
            ;;
        "linux-rhel" | "linux-centos" | "linux-rocky" | "linux-almalinux" | "linux-fedora")
            if ! sudo "$PACKAGE_MANAGER" install -y ShellCheck 2>/dev/null; then
                if ! sudo "$PACKAGE_MANAGER" install -y shellcheck 2>/dev/null; then
                    log_warning "ShellCheck not available in $PACKAGE_MANAGER repos, install manually: https://github.com/koalaman/shellcheck#installing"
                fi
            fi
            ;;
    esac
}

# Install shfmt (shell formatter)
# Fedora: in default repos. RHEL: not in EPEL — download static binary.
install_shfmt() {
    if command_exists shfmt; then
        log_success "shfmt already installed"
        return
    fi

    log_info "Installing shfmt..."
    case "$OS-$DISTRO" in
        "linux-ubuntu" | "linux-debian")
            if ! sudo apt install -y shfmt 2>/dev/null; then
                _install_shfmt_binary
            fi
            ;;
        "linux-fedora")
            sudo dnf install -y shfmt
            ;;
        "linux-rhel" | "linux-centos" | "linux-rocky" | "linux-almalinux")
            _install_shfmt_binary
            ;;
    esac
}

_install_shfmt_binary() {
    local arch
    arch=$(uname -m)
    case "$arch" in
        aarch64) arch="arm64" ;;
        x86_64) arch="amd64" ;;
        *)
            log_warning "Unsupported architecture: $arch. Install shfmt manually."
            return
            ;;
    esac
    local version
    version=$(curl -fsSL -o /dev/null -w "%{url_effective}" \
        "https://github.com/mvdan/sh/releases/latest" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+')
    if [ -z "$version" ]; then
        log_warning "Could not determine shfmt version. Install shfmt manually."
        return
    fi
    mkdir -p "$HOME/.local/bin"
    curl -fsSL \
        "https://github.com/mvdan/sh/releases/download/${version}/shfmt_${version}_linux_${arch}" \
        -o "$HOME/.local/bin/shfmt"
    chmod +x "$HOME/.local/bin/shfmt"
    log_success "shfmt ${version} installed to ~/.local/bin"
}

# Install lefthook (git hooks manager)
# Not in Fedora or RHEL repos — download binary from GitHub releases
install_lefthook() {
    if command_exists lefthook; then
        log_success "Lefthook already installed"
        return
    fi

    if [ "$OS" != "linux" ]; then
        return
    fi

    log_info "Installing Lefthook..."
    local arch
    arch=$(uname -m)
    case "$arch" in
        aarch64) arch="arm64" ;;
        x86_64) arch="x86_64" ;;
        *)
            log_warning "Unsupported architecture: $arch. Install lefthook manually."
            return
            ;;
    esac
    local version
    version=$(curl -fsSL -o /dev/null -w "%{url_effective}" \
        "https://github.com/evilmartians/lefthook/releases/latest" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    if [ -z "$version" ]; then
        log_warning "Could not determine lefthook version. Install lefthook manually."
        return
    fi
    mkdir -p "$HOME/.local/bin"
    curl -fsSL \
        "https://github.com/evilmartians/lefthook/releases/download/v${version}/lefthook_${version}_Linux_${arch}" \
        -o "$HOME/.local/bin/lefthook"
    chmod +x "$HOME/.local/bin/lefthook"
}

# Install neovim
install_neovim() {
    if command_exists nvim; then
        log_success "Neovim already installed"
        return
    fi

    log_info "Installing Neovim..."
    case "$OS-$DISTRO" in
        "linux-ubuntu" | "linux-debian")
            sudo apt install -y neovim
            ;;
        "linux-rhel" | "linux-centos" | "linux-rocky" | "linux-almalinux" | "linux-fedora")
            sudo "$PACKAGE_MANAGER" install -y neovim
            ;;
    esac
}

# Install bat (for delta syntax themes)
install_bat() {
    if command_exists bat; then
        log_success "Bat already installed"
        return
    fi

    log_info "Installing Bat..."
    case "$OS-$DISTRO" in
        "linux-ubuntu" | "linux-debian")
            sudo apt install -y bat
            ;;
        "linux-rhel" | "linux-centos" | "linux-rocky" | "linux-almalinux" | "linux-fedora")
            sudo "$PACKAGE_MANAGER" install -y bat
            ;;
    esac
}

# Install delta (git diff pager)
install_delta() {
    if command_exists delta; then
        log_success "Delta already installed"
        return
    fi

    log_info "Installing Delta..."
    case "$OS-$DISTRO" in
        "linux-ubuntu" | "linux-debian")
            if ! sudo apt install -y git-delta 2>/dev/null; then
                log_warning "Delta not in repos, install manually: https://github.com/dandavison/delta/releases"
            fi
            ;;
        "linux-rhel" | "linux-centos" | "linux-rocky" | "linux-almalinux" | "linux-fedora")
            if ! sudo "$PACKAGE_MANAGER" install -y git-delta 2>/dev/null; then
                log_warning "Delta not in repos, install manually: https://github.com/dandavison/delta/releases"
            fi
            ;;
    esac
}

# Install git-cliff (changelog generator)
# Not in Fedora or RHEL repos — download binary from GitHub releases
install_gitcliff() {
    if command_exists git-cliff; then
        log_success "git-cliff already installed"
        return
    fi

    if [ "$OS" != "linux" ]; then
        return
    fi

    log_info "Installing git-cliff..."
    local arch
    arch=$(uname -m)
    case "$arch" in
        aarch64) arch="aarch64" ;;
        x86_64) arch="x86_64" ;;
        *)
            log_warning "Unsupported architecture: $arch. Install git-cliff manually."
            return
            ;;
    esac

    local version
    version=$(curl -fsSL -o /dev/null -w "%{url_effective}" \
        "https://github.com/orhun/git-cliff/releases/latest" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    if [ -z "$version" ]; then
        log_warning "Could not determine git-cliff version. Install git-cliff manually."
        return
    fi

    local tmp_dir
    tmp_dir=$(mktemp -d)
    local tarball="git-cliff-${version}-${arch}-unknown-linux-musl.tar.gz"
    curl -fsSL \
        "https://github.com/orhun/git-cliff/releases/download/v${version}/${tarball}" \
        -o "$tmp_dir/git-cliff.tar.gz"
    tar -xzf "$tmp_dir/git-cliff.tar.gz" -C "$tmp_dir"
    mkdir -p "$HOME/.local/bin"
    local binary
    binary=$(find "$tmp_dir" -name "git-cliff" -type f | head -1)
    mv "$binary" "$HOME/.local/bin/git-cliff"
    chmod +x "$HOME/.local/bin/git-cliff"
    rm -rf "$tmp_dir"
    log_success "git-cliff ${version} installed to ~/.local/bin"
}

# Install direnv (environment loader)
install_direnv() {
    if command_exists direnv; then
        log_success "direnv already installed"
        return
    fi
    log_info "Installing direnv..."
    case "$OS-$DISTRO" in
        "linux-ubuntu" | "linux-debian")
            if ! sudo apt install -y direnv 2>/dev/null; then
                log_warning "direnv not available in apt repos, falling back to curl install..."
                curl -sfL https://direnv.net/install.sh | bash
            fi
            ;;
        "linux-fedora")
            sudo dnf install -y direnv
            ;;
        "linux-rhel" | "linux-centos" | "linux-rocky" | "linux-almalinux")
            # direnv is not in EPEL 9 — use the official installer
            curl -sfL https://direnv.net/install.sh | bash
            ;;
    esac
    if ! command_exists direnv; then
        log_warning "direnv installation failed — install manually: https://direnv.net"
    fi
}

# Install jq (JSON processor)
install_jq() {
    if command_exists jq; then
        log_success "jq already installed"
        return
    fi

    log_info "Installing jq..."
    case "$OS-$DISTRO" in
        "linux-ubuntu" | "linux-debian")
            sudo apt install -y jq
            ;;
        "linux-rhel" | "linux-centos" | "linux-rocky" | "linux-almalinux" | "linux-fedora")
            sudo "$PACKAGE_MANAGER" install -y jq
            ;;
    esac
}

# Install yq (YAML processor — mikefarah/yq, the Go version)
# Ubuntu's apt yq is a Python wrapper with different syntax, so always use the binary
install_yq() {
    if command_exists yq; then
        log_success "yq already installed"
        return
    fi

    log_info "Installing yq..."
    case "$OS-$DISTRO" in
        "linux-fedora")
            sudo dnf install -y yq
            ;;
        "linux-ubuntu" | "linux-debian" | "linux-rhel" | "linux-centos" | "linux-rocky" | "linux-almalinux")
            _install_yq_binary
            ;;
    esac
}

_install_yq_binary() {
    local arch
    arch=$(uname -m)
    case "$arch" in
        aarch64) arch="arm64" ;;
        x86_64) arch="amd64" ;;
        *)
            log_warning "Unsupported architecture: $arch. Install yq manually."
            return
            ;;
    esac
    local version
    version=$(curl -fsSL -o /dev/null -w "%{url_effective}" \
        "https://github.com/mikefarah/yq/releases/latest" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    if [ -z "$version" ]; then
        log_warning "Could not determine yq version. Install yq manually."
        return
    fi
    mkdir -p "$HOME/.local/bin"
    curl -fsSL \
        "https://github.com/mikefarah/yq/releases/download/v${version}/yq_linux_${arch}" \
        -o "$HOME/.local/bin/yq"
    chmod +x "$HOME/.local/bin/yq"
    log_success "yq v${version} installed to ~/.local/bin"
}

# Install glab (GitLab CLI)
install_glab() {
    if command_exists glab; then
        log_success "glab already installed"
        return
    fi

    log_info "Installing glab..."
    case "$OS-$DISTRO" in
        "linux-ubuntu" | "linux-debian")
            if ! sudo apt install -y glab 2>/dev/null; then
                _install_glab_binary
            fi
            ;;
        "linux-fedora")
            sudo dnf install -y glab
            ;;
        "linux-rhel" | "linux-centos" | "linux-rocky" | "linux-almalinux")
            if ! sudo "$PACKAGE_MANAGER" install -y glab 2>/dev/null; then
                _install_glab_binary
            fi
            ;;
    esac
}

_install_glab_binary() {
    local arch
    arch=$(uname -m)
    case "$arch" in
        aarch64) arch="arm64" ;;
        x86_64) arch="x86_64" ;;
        *)
            log_warning "Unsupported architecture: $arch. Install glab manually."
            return
            ;;
    esac
    local version
    version=$(curl -fsSL -o /dev/null -w "%{url_effective}" \
        "https://gitlab.com/gitlab-org/cli/-/releases/permalink/latest" \
        | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    if [ -z "$version" ]; then
        log_warning "Could not determine glab version. Install glab manually."
        return
    fi
    local tmp_dir
    tmp_dir=$(mktemp -d)
    curl -fsSL \
        "https://gitlab.com/gitlab-org/cli/-/releases/v${version}/downloads/glab_${version}_Linux_${arch}.tar.gz" \
        -o "$tmp_dir/glab.tar.gz"
    tar -xzf "$tmp_dir/glab.tar.gz" -C "$tmp_dir"
    mkdir -p "$HOME/.local/bin"
    local binary
    binary=$(find "$tmp_dir" -name "glab" -type f | head -1)
    mv "$binary" "$HOME/.local/bin/glab"
    chmod +x "$HOME/.local/bin/glab"
    rm -rf "$tmp_dir"
    log_success "glab v${version} installed to ~/.local/bin"
}

# Install tmux (terminal multiplexer)
install_tmux() {
    if command_exists tmux; then
        log_success "tmux already installed"
        return
    fi

    log_info "Installing tmux..."
    case "$OS-$DISTRO" in
        "linux-ubuntu" | "linux-debian")
            sudo apt install -y tmux
            ;;
        "linux-rhel" | "linux-centos" | "linux-rocky" | "linux-almalinux" | "linux-fedora")
            sudo "$PACKAGE_MANAGER" install -y tmux
            ;;
    esac
}

# Install Catppuccin theme for tmux (manual install — avoids TPM name conflict issues)
install_tmux_theme() {
    local plugin_dir="$HOME/.config/tmux/plugins/catppuccin/tmux"

    if [ -d "$plugin_dir" ]; then
        log_success "Catppuccin tmux theme already installed"
        return
    fi

    if ! command_exists tmux; then
        return
    fi

    log_info "Installing Catppuccin tmux theme..."
    mkdir -p "$(dirname "$plugin_dir")"
    git clone --depth=1 -b v2.3.0 https://github.com/catppuccin/tmux.git "$plugin_dir"
    log_success "Catppuccin tmux theme installed"
}

# Install herdr (runtime for AI coding agents)
install_herdr() {
    if command_exists herdr; then
        log_success "herdr already installed"
        return
    fi

    if [ "$OS" != "linux" ]; then
        return
    fi

    log_info "Installing herdr..."
    curl -fsSL https://herdr.dev/install.sh | sh
}

# Install eza (modern ls replacement)
# Not in EPEL 9 — fall back to GitHub binary release on RHEL-family
install_eza() {
    if command_exists eza; then
        log_success "eza already installed"
        return
    fi

    log_info "Installing eza..."
    case "$OS-$DISTRO" in
        "linux-ubuntu" | "linux-debian")
            if ! sudo apt install -y eza 2>/dev/null; then
                _install_eza_binary
            fi
            ;;
        "linux-fedora")
            sudo dnf install -y eza
            ;;
        "linux-rhel" | "linux-centos" | "linux-rocky" | "linux-almalinux")
            if ! sudo "$PACKAGE_MANAGER" install -y eza 2>/dev/null; then
                _install_eza_binary
            fi
            ;;
    esac
}

_install_eza_binary() {
    local arch
    arch=$(uname -m)
    case "$arch" in
        aarch64) arch="aarch64" ;;
        x86_64) arch="x86_64" ;;
        *)
            log_warning "Unsupported architecture: $arch. Install eza manually."
            return
            ;;
    esac
    local version
    version=$(curl -fsSL -o /dev/null -w "%{url_effective}" \
        "https://github.com/eza-community/eza/releases/latest" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    if [ -z "$version" ]; then
        log_warning "Could not determine eza version. Install eza manually."
        return
    fi
    local tmp_dir
    tmp_dir=$(mktemp -d)
    curl -fsSL \
        "https://github.com/eza-community/eza/releases/download/v${version}/eza_${arch}-unknown-linux-musl.tar.gz" \
        -o "$tmp_dir/eza.tar.gz"
    tar -xzf "$tmp_dir/eza.tar.gz" -C "$tmp_dir"
    mkdir -p "$HOME/.local/bin"
    mv "$tmp_dir/eza" "$HOME/.local/bin/eza"
    chmod +x "$HOME/.local/bin/eza"
    rm -rf "$tmp_dir"
    log_success "eza ${version} installed to ~/.local/bin"
}

# Install ripgrep (modern grep replacement)
install_ripgrep() {
    if command_exists rg; then
        log_success "ripgrep already installed"
        return
    fi

    log_info "Installing ripgrep..."
    case "$OS-$DISTRO" in
        "linux-ubuntu" | "linux-debian")
            sudo apt install -y ripgrep
            ;;
        "linux-rhel" | "linux-centos" | "linux-rocky" | "linux-almalinux" | "linux-fedora")
            sudo "$PACKAGE_MANAGER" install -y ripgrep
            ;;
    esac
}

# Install fd (modern find replacement)
# Ubuntu/Debian package the binary as fdfind to avoid a naming conflict
install_fd() {
    if command_exists fd || command_exists fdfind; then
        log_success "fd already installed"
        return
    fi

    log_info "Installing fd..."
    case "$OS-$DISTRO" in
        "linux-ubuntu" | "linux-debian")
            sudo apt install -y fd-find
            ;;
        "linux-rhel" | "linux-centos" | "linux-rocky" | "linux-almalinux" | "linux-fedora")
            sudo "$PACKAGE_MANAGER" install -y fd-find
            ;;
    esac
}

# Install zsh plugins (autosuggestions, syntax highlighting, fzf-tab)
# macOS: autosuggestions/syntax-highlighting handled by Brewfile; fzf-tab cloned on all platforms
install_zsh_plugins() {
    if [ "$OS" = "linux" ]; then
        log_info "Installing zsh plugins..."
        case "$OS-$DISTRO" in
            "linux-ubuntu" | "linux-debian")
                sudo apt install -y zsh-autosuggestions zsh-syntax-highlighting 2>/dev/null \
                    || log_warning "zsh plugins not available in apt repos"
                ;;
            "linux-fedora")
                sudo dnf install -y zsh-autosuggestions zsh-syntax-highlighting
                ;;
            "linux-rhel" | "linux-centos" | "linux-rocky" | "linux-almalinux")
                sudo "$PACKAGE_MANAGER" install -y zsh-autosuggestions zsh-syntax-highlighting 2>/dev/null \
                    || log_warning "zsh plugins not available — autosuggestions and syntax highlighting will be disabled"
                ;;
        esac
    fi

    # fzf-tab is a git submodule — populated by deploy_dotfiles via submodule update --init
}

# Prompt user to set zsh as the default login shell
configure_default_shell() {
    local zsh_path
    zsh_path=$(command -v zsh 2>/dev/null)

    if [ -z "$zsh_path" ]; then
        log_warning "zsh not found in PATH — skipping shell configuration"
        return
    fi

    if [ "$SHELL" = "$zsh_path" ]; then
        log_success "zsh is already your default shell"
        return
    fi

    if ! command_exists chsh; then
        log_info "chsh not found — installing util-linux-user..."
        case "$OS-$DISTRO" in
            "linux-rhel" | "linux-centos" | "linux-rocky" | "linux-almalinux" | "linux-fedora")
                sudo "$PACKAGE_MANAGER" install -y util-linux-user
                ;;
            "linux-ubuntu" | "linux-debian")
                sudo apt install -y passwd
                ;;
        esac
    fi

    if ! grep -qF "$zsh_path" /etc/shells 2>/dev/null; then
        log_info "Adding $zsh_path to /etc/shells..."
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    if chsh -s "$zsh_path" 2>/dev/null; then
        log_success "Default shell set to zsh — restart your terminal to apply"
    else
        # chsh fails on domain/AD accounts — fall back to exec zsh in .bash_profile
        log_warning "chsh failed (likely a domain account) — adding 'exec zsh' to ~/.bashrc instead"
        local bashrc="$HOME/.bashrc"
        if ! grep -q "exec zsh" "$bashrc" 2>/dev/null; then
            printf '\n# Launch zsh for interactive sessions (chsh unavailable on domain accounts)\n[ -t 1 ] && command -v zsh >/dev/null && exec zsh\n' >> "$bashrc"
        fi
        log_success "Added 'exec zsh' to ~/.bashrc — restart your terminal to apply"
    fi
}

# Create backup of existing config files
backup_existing_configs() {
    log_info "Creating backup of existing configuration files..."

    local files_backed_up=0
    mkdir -p "$BACKUP_DIR"

    for config_file in "${CONFIG_FILES[@]}"; do
        local full_path="$HOME/$config_file"

        if [ -e "$full_path" ] && [ ! -L "$full_path" ]; then
            log_info "Backing up $config_file"
            mkdir -p "$BACKUP_DIR/$(dirname "$config_file")"
            mv "$full_path" "$BACKUP_DIR/$config_file"
            files_backed_up=$((files_backed_up + 1))
        fi
    done

    if [ $files_backed_up -eq 0 ]; then
        log_success "No existing config files found to backup"
        rmdir "$BACKUP_DIR" 2>/dev/null || true
    else
        log_success "Backed up $files_backed_up config files to $BACKUP_DIR"
    fi
}


# Deploy dotfiles using stow
deploy_dotfiles() {
    log_info "Deploying dotfiles packages..."

    if ! command_exists stow; then
        log_error "GNU Stow is not installed. Please install it first."
        exit 1
    fi

    log_info "Initialising git submodules..."
    git -C "$SCRIPT_DIR" submodule update --init --recursive
    log_success "Submodules initialised"

    # Deploy each package — use --restow (-R) so re-runs and new files in
    # existing packages are handled correctly on non-fresh machines
    for package in $PACKAGES_TO_STOW; do
        if [ -d "$SCRIPT_DIR/$package" ]; then
            log_info "Deploying $package package..."
            stow -d "$SCRIPT_DIR" -t "$HOME" -R "$package"
        else
            log_warning "Package directory '$package' not found, skipping..."
        fi
    done

    log_success "All dotfiles packages deployed successfully!"
}

# Migrate old XDG git config to ~/.gitconfig layout
# Removes stow-managed symlinks from the old ~/.config/git/ location so stow -R
# does not conflict when it creates the new ~/. symlinks.
migrate_git_config() {
    local old_dir="$HOME/.config/git"

    # Stow linked the whole directory; remove it so the new ~/. symlinks can be created
    if [ -L "$old_dir" ]; then
        log_info "Removing old git directory symlink: $old_dir"
        rm "$old_dir"
        log_success "Git config migration complete"
    fi

    # Ensure the directory exists so the config.local include in .gitconfig resolves
    mkdir -p "$old_dir"
}


main() {
    echo "🧩 Dotfiles Installation Script"
    echo "================================"
    echo ""

    # Parse command line arguments
    local skip_backup=false
    local skip_deploy=false
    local configure_zsh="" # empty = prompt, "true" = yes, "false" = no

    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-backup)
                skip_backup=true
                shift
                ;;
            --skip-deploy)
                skip_deploy=true
                shift
                ;;
            --deps-only)
                skip_backup=true
                skip_deploy=true
                shift
                ;;
            --zsh)
                configure_zsh=true
                shift
                ;;
            --no-zsh)
                configure_zsh=false
                shift
                ;;
            -h | --help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --deps-only     Install dependencies only, no config changes"
                echo "  --skip-backup   Skip backing up existing config files"
                echo "  --skip-deploy   Skip deploying dotfiles (backup and install deps only)"
                echo "  --zsh           Configure zsh as default shell (non-interactive)"
                echo "  --no-zsh        Skip zsh plugins and shell switch (non-interactive)"
                echo "  -h, --help      Show this help message"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done

    detect_os
    install_package_manager

    # Ask about zsh once, upfront — skip if it's already the default shell
    if [ -z "$configure_zsh" ]; then
        local zsh_path
        zsh_path=$(command -v zsh 2>/dev/null)
        if [ -n "$zsh_path" ] && [ "$SHELL" = "$zsh_path" ]; then
            configure_zsh=false
            log_success "zsh is already your default shell — skipping"
        else
            printf "Configure zsh as your default shell? [Y/n] "
            read -r _zsh_response || _zsh_response="y"
            case "$_zsh_response" in
                [nN][oO] | [nN]) configure_zsh=false ;;
                *) configure_zsh=true ;;
            esac
        fi
    fi

    enable_epel
    install_core_deps

    # macOS: install all tools via Brewfile
    # Linux: each function uses the native package manager
    run_brew_bundle

    if [ "$OS" = "linux" ]; then
        install_starship
        install_fastfetch
        install_zoxide
        install_fzf
        install_shellcheck
        install_shfmt
        install_lefthook
        install_neovim
        install_bat
        install_delta
        install_gitcliff
        install_direnv
        install_jq
        install_yq
        install_glab
        install_tmux
        install_herdr
        install_eza
        install_ripgrep
        install_fd
    fi
    install_tmux_theme
    [ "$configure_zsh" != false ] && install_zsh_plugins

    if [ "$skip_deploy" = true ]; then
        log_success "Dependencies installation complete! 🎉"
        echo ""
        echo "To deploy dotfiles manually:"
        echo "1. Backup existing configs if needed"
        echo "2. Run: stow $PACKAGES_TO_STOW"
        echo '3. Reload your shell: exec $SHELL'
        return
    fi

    echo ""
    log_info "Starting dotfiles deployment..."
    echo ""

    # Check for an existing backup and offer to restore before proceeding
    local existing_backup=""
    for _d in "$HOME"/.dotfiles-backup-* "$HOME"/.dotfiles-snapshot-*; do
        [ -d "$_d" ] && existing_backup="$_d"
    done
    if [ -n "$existing_backup" ]; then
        log_warning "Existing backup found: $existing_backup"
        printf "Restore from this backup instead of deploying? [y/N] "
        read -r _restore_response || _restore_response="n"
        case "$_restore_response" in
            [yY][eE][sS] | [yY])
                log_info "Restoring from $existing_backup..."
                while IFS= read -r -d '' _file; do
                    _rel="${_file#"$existing_backup"/}"
                    [ "$_rel" = "restore.sh" ] && continue
                    mkdir -p "$HOME/$(dirname "$_rel")"
                    local _target="$HOME/$_rel"
                    [ -L "$_target" ] || [ -e "$_target" ] && rm -rf "${_target:?}"
                    cp -r "$_file" "$HOME/$_rel"
                done < <(find "$existing_backup" -type f -print0)
                log_success "Restored — restart your shell: exec \$SHELL"
                return
                ;;
        esac
    fi

    migrate_git_config

    if [ "$skip_backup" = false ]; then
        backup_existing_configs
    else
        log_warning "Skipping backup (--skip-backup specified)"
    fi

    deploy_dotfiles

    [ "$configure_zsh" = true ] && configure_default_shell

    log_info "Installing git hooks..."
    # Ensure ~/.local/bin is in PATH so lefthook is findable if it was just installed there
    export PATH="$HOME/.local/bin:$PATH"
    lefthook install && log_success "Lefthook hooks installed"

    # Rebuild bat cache — clear first to handle version mismatches after upgrades
    if command_exists bat; then
        log_info "Rebuilding bat cache for delta themes..."
        bat cache --clear >/dev/null 2>&1 || true
        bat cache --build >/dev/null 2>&1 && log_success "Bat cache rebuilt"
    fi

    echo ""
    log_success "Installation complete!"
    if [ -d "$BACKUP_DIR" ]; then
        log_info "Backup at: $BACKUP_DIR"
    fi
    echo ""
    echo "Restart your shell: exec \$SHELL"
}

# Run main function
main "$@"
