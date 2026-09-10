#!/bin/bash

# Dotfiles uninstall script
# Removes stow symlinks, cloned plugins, and restores original configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions — all write to stderr so command substitution (backup_dir=$(fn))
# only captures the intended return value, not incidental log output.
log_info() { echo -e "${BLUE}[INFO]${NC} $1" >&2; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1" >&2; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1" >&2; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Find most recent backup
find_backup() {
    local latest_backup=""

    for backup_dir in "$HOME"/.dotfiles-backup-*/; do
        [ -d "$backup_dir" ] && latest_backup="$backup_dir"
    done

    echo "$latest_backup"
}

# List available backups
list_backups() {
    local found_backups=()

    for backup_dir in "$HOME"/.dotfiles-backup-*/; do
        [ -d "$backup_dir" ] && found_backups+=("$backup_dir")
    done

    if [ ${#found_backups[@]} -eq 0 ]; then
        return 1
    fi

    echo "Available backups:" >&2
    for i in "${!found_backups[@]}"; do
        local backup_date
        backup_date=$(basename "${found_backups[$i]}" | sed 's/.dotfiles-backup-//')
        echo "  $((i + 1)). ${found_backups[$i]} (created: ${backup_date})" >&2
    done

    return 0
}

# Snapshot current live config before removing anything
# Uses cp -rL to dereference symlinks so actual file content is saved,
# not pointers back into the dotfiles repo that become useless after unstow
snapshot_current_config() {
    local snapshot_dir
    snapshot_dir="$HOME/.dotfiles-snapshot-$(date +%Y%m%d-%H%M%S)"
    local files_snapped=0

    log_info "Creating pre-uninstall snapshot..."
    mkdir -p "$snapshot_dir"

    local managed=(
        ".zshrc"
        ".bashrc"
        ".bash_profile"
        ".zprofile"
        ".config/shell"
        ".config/zsh"
        ".config/bash"
        ".gitconfig"
        ".gitignore_global"
        ".catppuccin.gitconfig"
        ".config/starship.toml"
        ".config/fzf"
        ".config/nvim"
        ".config/bat"
        ".tmux.conf"
        ".tmux.conf.local"
    )

    for rel_path in "${managed[@]}"; do
        local full_path="$HOME/$rel_path"
        if [ -e "$full_path" ]; then
            mkdir -p "$snapshot_dir/$(dirname "$rel_path")"
            cp -rL "$full_path" "$snapshot_dir/$rel_path" 2>/dev/null || true
            files_snapped=$((files_snapped + 1))
        fi
    done

    if [ $files_snapped -gt 0 ]; then
        log_success "Snapshot saved to $snapshot_dir"
        log_info "To restore manually: cp -rL \"$snapshot_dir/.\" \"\$HOME/\""
    else
        rmdir "$snapshot_dir" 2>/dev/null || true
        log_warning "No managed config files found to snapshot"
    fi
}

# Unstow all dotfiles packages
unstow_dotfiles() {
    log_info "Removing dotfiles symlinks..."

    if [ -f "$SCRIPT_DIR/.stow-local-ignore" ]; then
        if command_exists stow; then
            stow -d "$SCRIPT_DIR" -t "$HOME" -D shell bash zsh git starship fzf nvim bat tmux \
                || log_warning "stow -D reported errors — some symlinks may remain"
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

# Manual symlink removal (fallback when stow is not available)
manual_unstow() {
    local symlinks=(
        "$HOME/.zshrc"
        "$HOME/.bashrc"
        "$HOME/.bash_profile"
        "$HOME/.zprofile"
        "$HOME/.config/shell"
        "$HOME/.config/zsh/.zshrc"
        "$HOME/.config/zsh/.zprofile"
        "$HOME/.config/bash/.bashrc"
        "$HOME/.config/bash/.bash_profile"
        "$HOME/.gitconfig"
        "$HOME/.gitignore_global"
        "$HOME/.catppuccin.gitconfig"
        "$HOME/.config/starship.toml"
        "$HOME/.config/fzf"
        "$HOME/.config/nvim"
        "$HOME/.config/bat/config"
        "$HOME/.config/bat/themes"
        "$HOME/.config/tmux/tmux.conf"
    )

    for symlink in "${symlinks[@]}"; do
        if [ -L "$symlink" ]; then
            rm "$symlink"
            log_info "Removed symlink: $symlink"
        fi
    done
}

# Remove plugins and binaries installed by install.sh outside of stow packages
remove_cloned_plugins() {
    log_info "Removing cloned plugins..."

    # oh-my-tmux: remove TPM and all installed plugins, then the ~/.tmux.conf symlink
    if [ -d "$HOME/.tmux/plugins" ]; then
        rm -rf "$HOME/.tmux/plugins"
        log_info "Removed TPM and tmux plugins (~/.tmux/plugins/)"
    fi
    rmdir "$HOME/.tmux" 2>/dev/null || true
    if [ -L "$HOME/.tmux.conf" ]; then
        rm "$HOME/.tmux.conf"
        log_info "Removed ~/.tmux.conf symlink"
    fi

    # GitHub release binaries downloaded by install.sh to ~/.local/bin
    # Only removed if present — package-manager installs go to /usr/bin and are untouched.
    log_info "Removing ~/.local/bin binaries installed by install.sh..."
    local local_bins=(shfmt lefthook git-cliff yq glab eza)
    local bin
    for bin in "${local_bins[@]}"; do
        local p="$HOME/.local/bin/$bin"
        if [ -f "$p" ]; then
            rm "$p"
            log_info "Removed ~/.local/bin/$bin"
        fi
    done

    # Linux fonts installed by install_nerd_font() to ~/.local/share/fonts/
    # macOS fonts are managed by Homebrew casks — not removed here.
    local font_dir="$HOME/.local/share/fonts/JetBrainsMono"
    if [ -d "$font_dir" ]; then
        rm -rf "$font_dir"
        fc-cache -fv >/dev/null 2>&1
        log_info "Removed JetBrains Mono Nerd Font"
    fi

    log_success "Plugins, local binaries, and fonts removed"
}

# Interactive backup selection
select_backup() {
    if ! list_backups; then
        log_error "No backups found in $HOME/.dotfiles-backup-*"
        echo "" >&2
        echo "If you have a backup elsewhere, you can restore it manually:" >&2
        echo "1. Copy your backup files to their original locations" >&2
        echo "2. Remove any dotfiles symlinks" >&2
        return 1
    fi

    echo "" >&2
    read -r -p "Select backup to restore (number) or 'q' to quit: " choice

    if [ "$choice" = "q" ]; then
        log_info "Uninstall cancelled"
        exit 0
    fi

    local found_backups=()

    for backup_dir in "$HOME"/.dotfiles-backup-*/; do
        [ -d "$backup_dir" ] && found_backups+=("$backup_dir")
    done

    if [[ $choice =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#found_backups[@]} ]; then
        echo "${found_backups[$((choice - 1))]}"
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

    while IFS= read -r -d '' file; do
        local relative_path="${file#"$backup_dir"/}"
        local target_path="$HOME/$relative_path"

        if [[ $relative_path == "restore.sh" ]]; then
            continue
        fi

        mkdir -p "$(dirname "$target_path")"

        if [ -L "$target_path" ] || [ -e "$target_path" ]; then
            rm -rf "$target_path"
        fi

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

    local auto_mode=false
    local backup_dir=""
    local skip_plugins=false
    local skip_snapshot=false

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
            --skip-plugins)
                skip_plugins=true
                shift
                ;;
            --skip-snapshot)
                skip_snapshot=true
                shift
                ;;
            -h | --help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --auto             Use most recent backup automatically"
                echo "  --backup DIR       Use specific backup directory"
                echo "  --skip-plugins     Keep ~/.tmux/plugins/, ~/.tmux.conf, ~/.local/bin binaries, and fonts"
                echo "  --skip-snapshot    Skip pre-uninstall config snapshot"
                echo "  -h, --help         Show this help message"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information" >&2
                exit 1
                ;;
        esac
    done

    [ "$skip_snapshot" = false ] && snapshot_current_config

    unstow_dotfiles

    if [ "$skip_plugins" = false ]; then
        remove_cloned_plugins
    fi

    if [ "$auto_mode" = true ]; then
        backup_dir=$(find_backup)
        if [ -z "$backup_dir" ]; then
            log_error "No backup found for auto mode"
            exit 1
        fi
        log_info "Auto-selected backup: $backup_dir"
    elif [ -z "$backup_dir" ]; then
        if ! backup_dir=$(select_backup); then
            exit 1
        fi
    fi

    restore_backup "$backup_dir"

    echo "" >&2
    log_success "Dotfiles successfully uninstalled! 🎉"
    echo "" >&2
    echo "Your original configuration has been restored." >&2
    echo 'You may want to restart your shell: exec $SHELL' >&2
}

# Run main function
main "$@"
