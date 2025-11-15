#!/bin/bash

# Dotfiles installation script
# Automatically installs requirements based on OS detection

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
    if [[ "$OSTYPE" == "darwin"* ]]; then
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
        "linux-ubuntu"|"linux-debian")
            if ! command_exists apt; then
                log_error "apt package manager not found"
                exit 1
            fi
            log_info "Updating package lists..."
            sudo apt update
            ;;
        "linux-rhel"|"linux-centos"|"linux-rocky"|"linux-almalinux")
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
        "macos")
            if ! command_exists brew; then
                log_info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                # Add Homebrew to PATH for current session
                eval "$(/opt/homebrew/bin/brew shellenv)"
            else
                log_success "Homebrew already installed"
            fi
            ;;
    esac
}

# Install core dependencies
install_core_deps() {
    log_info "Installing core dependencies..."
    
    case "$OS-$DISTRO" in
        "linux-ubuntu"|"linux-debian")
            sudo apt install -y git stow zsh curl wget
            ;;
        "linux-rhel"|"linux-centos"|"linux-rocky"|"linux-almalinux"|"linux-fedora")
            sudo $PACKAGE_MANAGER install -y git stow zsh curl wget
            ;;
        "macos")
            brew install git stow
            # zsh is built-in on macOS
            ;;
    esac
}

# Install starship prompt
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
        "linux-ubuntu"|"linux-debian")
            # Try package first, fallback to manual install if not available
            if ! sudo apt install -y fastfetch 2>/dev/null; then
                log_warning "Fastfetch not available in repos, skipping..."
            fi
            ;;
        "linux-fedora")
            sudo dnf install -y fastfetch
            ;;
        "linux-rhel"|"linux-centos"|"linux-rocky"|"linux-almalinux")
            log_warning "Fastfetch not available in RHEL repos, skipping..."
            ;;
        "macos")
            brew install fastfetch
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
        "linux-ubuntu"|"linux-debian")
            if ! sudo apt install -y zoxide 2>/dev/null; then
                # Fallback to manual install
                curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
            fi
            ;;
        "linux-rhel"|"linux-centos"|"linux-rocky"|"linux-almalinux"|"linux-fedora")
            if ! sudo $PACKAGE_MANAGER install -y zoxide 2>/dev/null; then
                # Fallback to manual install
                curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
            fi
            ;;
        "macos")
            brew install zoxide
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
        "linux-ubuntu"|"linux-debian")
            sudo apt install -y fzf
            ;;
        "linux-rhel"|"linux-centos"|"linux-rocky"|"linux-almalinux"|"linux-fedora")
            sudo $PACKAGE_MANAGER install -y fzf
            ;;
        "macos")
            brew install fzf
            ;;
    esac
}

# Install neovim
install_neovim() {
    if command_exists nvim; then
        log_success "Neovim already installed"
        return
    fi
    
    log_info "Installing Neovim..."
    case "$OS-$DISTRO" in
        "linux-ubuntu"|"linux-debian")
            sudo apt install -y neovim
            ;;
        "linux-rhel"|"linux-centos"|"linux-rocky"|"linux-almalinux"|"linux-fedora")
            sudo $PACKAGE_MANAGER install -y neovim
            ;;
        "macos")
            brew install neovim
            ;;
    esac
}

# Main installation function
main() {
    echo "🧩 Dotfiles Installation Script"
    echo "================================"
    
    detect_os
    install_package_manager
    install_core_deps
    install_starship
    install_fastfetch
    install_zoxide
    install_fzf
    install_neovim
    
    echo ""
    log_success "Installation complete! 🎉"
    echo ""
    echo "Next steps:"
    echo "1. Clone your dotfiles repository"
    echo "2. cd into the dotfiles directory"
    echo "3. Run: stow shell zsh git starship fzf nvim"
    echo "4. Reload your shell: exec \$SHELL"
}

# Run main function
main "$@"