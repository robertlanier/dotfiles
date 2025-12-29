#!/bin/bash

# Dotfiles installation script
# Automatically installs requirements, backs up existing configs, and deploys dotfiles

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
PACKAGES_TO_STOW="shell bash zsh git starship fzf nvim vscode"
CONFIG_FILES=(
    ".zshrc"
    ".bashrc" 
    ".bash_profile"
    ".zprofile"
    ".gitconfig"
    ".config/starship.toml"
    ".config/nvim"
    ".config/git"
    ".config/zsh"
    ".config/bash"
    ".config/shell"
    ".config/fzf"
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

# Create backup of existing config files
backup_existing_configs() {
    log_info "Creating backup of existing configuration files..."
    
    local files_backed_up=0
    mkdir -p "$BACKUP_DIR"
    
    for config_file in "${CONFIG_FILES[@]}"; do
        local full_path="$HOME/$config_file"
        
        if [ -e "$full_path" ]; then
            log_info "Backing up $config_file"
            mkdir -p "$BACKUP_DIR/$(dirname "$config_file")"
            cp -r "$full_path" "$BACKUP_DIR/$config_file"
            files_backed_up=$((files_backed_up + 1))
        fi
    done
    
    if [ $files_backed_up -eq 0 ]; then
        log_success "No existing config files found to backup"
        rmdir "$BACKUP_DIR" 2>/dev/null || true
    else
        log_success "Backed up $files_backed_up config files to $BACKUP_DIR"
        
        # Create restore script
        create_restore_script
    fi
}

# Create restore script
create_restore_script() {
    local restore_script="$BACKUP_DIR/restore.sh"
    
    cat > "$restore_script" << 'EOF'
#!/bin/bash
# Restore script - reverts dotfiles installation

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "🔄 Dotfiles Restore Script"
echo "=========================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR"

# Check if we're in dotfiles directory and unstow packages
if [ -f "../.stow-local-ignore" ]; then
    log_info "Unstowing dotfiles packages..."
    cd ..
    stow -D shell bash zsh git starship fzf nvim vscode 2>/dev/null || true
    cd "$BACKUP_DIR"
else
    log_warning "Not in dotfiles directory, skipping unstow step"
fi

# Restore backed up files
log_info "Restoring backed up configuration files..."
files_restored=0

while IFS= read -r -d '' file; do
    relative_path="${file#$BACKUP_DIR/}"
    target_path="$HOME/$relative_path"
    
    # Remove existing symlink/file
    if [ -L "$target_path" ] || [ -e "$target_path" ]; then
        rm -rf "$target_path"
    fi
    
    # Restore backup
    mkdir -p "$(dirname "$target_path")"
    cp -r "$file" "$target_path"
    log_info "Restored $relative_path"
    files_restored=$((files_restored + 1))
done < <(find "$BACKUP_DIR" -type f -not -name "restore.sh" -print0)

log_success "Restored $files_restored configuration files"
echo ""
log_success "Dotfiles have been successfully reverted! 🎉"
log_info "Your original configuration has been restored."
log_info "You may want to restart your shell: exec \$SHELL"
EOF

    chmod +x "$restore_script"
    log_success "Created restore script at $restore_script"
}

# Deploy dotfiles using stow
deploy_dotfiles() {
    log_info "Deploying dotfiles packages..."
    
    # Check if we have GNU Stow
    if ! command_exists stow; then
        log_error "GNU Stow is not installed. Please install it first."
        exit 1
    fi
    
    # Deploy each package
    for package in $PACKAGES_TO_STOW; do
        if [ -d "$package" ]; then
            log_info "Deploying $package package..."
            stow "$package"
        else
            log_warning "Package directory '$package' not found, skipping..."
        fi
    done
    
    log_success "All dotfiles packages deployed successfully!"
}

# Verify installation
verify_installation() {
    log_info "Verifying installation..."
    
    local issues=0
    
    # Check if dotfiles are properly linked
    for config_file in ".zshrc" ".bashrc"; do
        if [ -L "$HOME/$config_file" ] && [ -e "$HOME/$config_file" ]; then
            log_success "$config_file is properly linked"
        elif [ -e "$HOME/$config_file" ]; then
            log_warning "$config_file exists but is not a symlink"
            issues=$((issues + 1))
        fi
    done
    
    # Check if tools are available
    local tools=("starship" "zoxide" "fzf" "nvim")
    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            log_success "$tool is available"
        else
            log_warning "$tool is not in PATH"
            issues=$((issues + 1))
        fi
    done
    
    if [ $issues -eq 0 ]; then
        log_success "Installation verification passed!"
    else
        log_warning "Installation verification found $issues issues (see above)"
    fi
}

# Main installation function
main() {
    echo "🧩 Dotfiles Installation Script"
    echo "================================"
    echo ""
    
    # Parse command line arguments
    local skip_backup=false
    local skip_deploy=false
    
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
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --deps-only     Install dependencies only, no config changes"
                echo "  --skip-backup   Skip backing up existing config files"  
                echo "  --skip-deploy   Skip deploying dotfiles (backup and install deps only)"
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
    install_core_deps
    install_starship
    install_fastfetch
    install_zoxide
    install_fzf
    install_neovim
    
    if [ "$skip_deploy" = true ]; then
        log_success "Dependencies installation complete! 🎉"
        echo ""
        echo "To deploy dotfiles manually:"
        echo "1. Backup existing configs if needed"
        echo "2. Run: stow $PACKAGES_TO_STOW"
        echo "3. Reload your shell: exec \$SHELL"
        return
    fi
    
    echo ""
    log_info "Starting dotfiles deployment..."
    echo ""
    
    if [ "$skip_backup" = false ]; then
        backup_existing_configs
    else
        log_warning "Skipping backup (--skip-backup specified)"
    fi
    
    deploy_dotfiles
    verify_installation
    
    echo ""
    log_success "Installation complete! 🎉"
    echo ""
    
    if [ -d "$BACKUP_DIR" ]; then
        echo "📁 Backup Information:"
        echo "   Location: $BACKUP_DIR"
        echo "   Restore:  $BACKUP_DIR/restore.sh"
        echo ""
    fi
    
    echo "🚀 Next Steps:"
    echo "1. Restart your shell: exec \$SHELL"
    echo "2. Enjoy your new dotfiles setup!"
    
    if [ -d "$BACKUP_DIR" ]; then
        echo "3. If something breaks, run: $BACKUP_DIR/restore.sh"
    fi
}

# Run main function
main "$@"