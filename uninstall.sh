#!/bin/bash

# Dotfiles uninstall script
# Completely removes dotfiles and restores original configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Find most recent backup
find_backup() {
    local backup_pattern="$HOME/.dotfiles-backup-*"
    local latest_backup=""
    
    for backup_dir in $backup_pattern; do
        if [ -d "$backup_dir" ]; then
            latest_backup="$backup_dir"
        fi
    done
    
    echo "$latest_backup"
}

# List available backups
list_backups() {
    local backup_pattern="$HOME/.dotfiles-backup-*"
    local found_backups=()
    
    for backup_dir in $backup_pattern; do
        if [ -d "$backup_dir" ]; then
            found_backups+=("$backup_dir")
        fi
    done
    
    if [ ${#found_backups[@]} -eq 0 ]; then
        return 1
    fi
    
    echo "Available backups:"
    for i in "${!found_backups[@]}"; do
        local backup_date=$(basename "${found_backups[$i]}" | sed 's/.dotfiles-backup-//')
        echo "  $((i+1)). ${found_backups[$i]} (created: ${backup_date})"
    done
    
    return 0
}

# Unstow dotfiles
unstow_dotfiles() {
    log_info "Removing dotfiles symlinks..."
    
    if [ -f ".stow-local-ignore" ]; then
        # We're in the dotfiles directory
        if command_exists stow; then
            stow -D shell zsh git starship fzf nvim 2>/dev/null || true
            log_success "Dotfiles unstowed"
        else
            log_warning "Stow not found, manually removing symlinks..."
            manual_unstow
        fi
    else
        log_warning "Not in dotfiles directory, manually removing symlinks..."
        manual_unstow
    fi
}

# Manual symlink removal
manual_unstow() {
    local symlinks=(
        "$HOME/.zshrc"
        "$HOME/.bashrc"
        "$HOME/.bash_profile"  
        "$HOME/.zprofile"
        "$HOME/.config/shell"
        "$HOME/.config/zsh"
        "$HOME/.config/bash"
        "$HOME/.config/git"
        "$HOME/.config/starship"
        "$HOME/.config/fzf"
        "$HOME/.config/nvim"
    )
    
    for symlink in "${symlinks[@]}"; do
        if [ -L "$symlink" ]; then
            rm "$symlink"
            log_info "Removed symlink: $(basename "$symlink")"
        fi
    done
}

# Interactive backup selection
select_backup() {
    if ! list_backups; then
        log_error "No backups found in $HOME/.dotfiles-backup-*"
        echo ""
        echo "If you have a backup elsewhere, you can restore it manually:"
        echo "1. Copy your backup files to their original locations"  
        echo "2. Remove any dotfiles symlinks"
        return 1
    fi
    
    echo ""
    read -p "Select backup to restore (number) or 'q' to quit: " choice
    
    if [ "$choice" = "q" ]; then
        log_info "Uninstall cancelled"
        exit 0
    fi
    
    local backup_pattern="$HOME/.dotfiles-backup-*"
    local found_backups=()
    
    for backup_dir in $backup_pattern; do
        if [ -d "$backup_dir" ]; then
            found_backups+=("$backup_dir")
        fi
    done
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#found_backups[@]} ]; then
        echo "${found_backups[$((choice-1))]}"
        return 0
    else
        log_error "Invalid selection"
        return 1
    fi
}

# Restore from backup
restore_backup() {
    local backup_dir="$1"
    
    if [ ! -d "$backup_dir" ]; then
        log_error "Backup directory not found: $backup_dir"
        return 1
    fi
    
    log_info "Restoring from backup: $backup_dir"
    
    local files_restored=0
    
    # Find all files in backup (excluding restore.sh)
    while IFS= read -r -d '' file; do
        local relative_path="${file#$backup_dir/}"
        local target_path="$HOME/$relative_path"
        
        # Skip restore.sh
        if [[ "$relative_path" == "restore.sh" ]]; then
            continue
        fi
        
        # Create target directory if needed
        mkdir -p "$(dirname "$target_path")"
        
        # Remove existing file/symlink
        if [ -L "$target_path" ] || [ -e "$target_path" ]; then
            rm -rf "$target_path"
        fi
        
        # Restore backup
        cp -r "$file" "$target_path"
        log_info "Restored: $relative_path"
        files_restored=$((files_restored + 1))
    done < <(find "$backup_dir" -type f -print0)
    
    log_success "Restored $files_restored files"
}

# Main function
main() {
    echo "🔄 Dotfiles Uninstall Script"
    echo "============================="
    echo ""
    
    # Parse arguments
    local auto_mode=false
    local backup_dir=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --auto)
                auto_mode=true
                shift
                ;;
            --backup)
                backup_dir="$2"
                shift 2
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --auto          Use most recent backup automatically"
                echo "  --backup DIR    Use specific backup directory"
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
    
    unstow_dotfiles
    
    if [ "$auto_mode" = true ]; then
        backup_dir=$(find_backup)
        if [ -z "$backup_dir" ]; then
            log_error "No backup found for auto mode"
            exit 1
        fi
        log_info "Auto-selected backup: $backup_dir"
    elif [ -z "$backup_dir" ]; then
        backup_dir=$(select_backup)
        if [ $? -ne 0 ]; then
            exit 1
        fi
    fi
    
    restore_backup "$backup_dir"
    
    echo ""
    log_success "Dotfiles successfully uninstalled! 🎉"
    echo ""
    echo "Your original configuration has been restored."
    echo "You may want to restart your shell: exec \$SHELL"
}

# Run main function
main "$@"