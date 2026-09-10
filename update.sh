#!/bin/bash
# update.sh — dotfiles update script
#
# Runs all update steps by default. Pass a step name to run only that step.
# Usage: ./update.sh [--help | STEP]
#
# ─── Adding a new update step ────────────────────────────────────────────────
#   1. Write an update_<name>() function in the UPDATE STEPS section below.
#   2. Add one run_step line to main():
#        run_step "Display Name"  update_<name>
#   3. Add one --help entry for the new step key.
# ─────────────────────────────────────────────────────────────────────────────

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── Logging (mirrors install.sh) ────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1" >&2; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1" >&2; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1" >&2; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

# Run a named step, logging pass/fail without aborting the script.
# set -e does not trigger for commands in an if condition, so a failing
# update function is caught here rather than killing the whole run.
run_step() {
    local label="$1"
    local fn="$2"
    echo -e "\n${CYAN}▶ ${label}${NC}" >&2
    if "$fn"; then
        return 0
    fi
    log_warning "'${label}' reported an error — continuing with remaining steps"
    return 1
}

# ─── UPDATE STEPS ─────────────────────────────────────────────────────────────

# Git submodules: oh-my-tmux, fzf-tab, zsh-fsh
update_submodules() {
    log_info "Updating git submodules to latest remote commits..."
    git -C "$SCRIPT_DIR" submodule update --remote --merge
    log_success "Submodules updated"
}

# TPM plugins declared in ~/.tmux.conf.local
update_tpm_plugins() {
    local tpm_update="$HOME/.tmux/plugins/tpm/bin/update_plugins"
    if [ ! -f "$tpm_update" ]; then
        log_warning "TPM not found at ~/.tmux/plugins/tpm — run install.sh first"
        return
    fi
    log_info "Updating TPM plugins..."
    "$tpm_update" all
    log_success "TPM plugins updated"
}

# Homebrew packages and Brewfile (macOS only; silently skips on Linux)
update_homebrew() {
    if ! command_exists brew; then
        return
    fi
    log_info "Updating Homebrew..."
    brew update
    log_info "Upgrading installed packages..."
    brew upgrade
    log_info "Installing any new Brewfile entries..."
    brew bundle --file="$SCRIPT_DIR/Brewfile"
    log_success "Homebrew up to date"
}

# Bat syntax/theme cache — rebuild after brew upgrades bat or its themes
update_bat_cache() {
    local bat_cmd
    bat_cmd=$(command -v bat 2>/dev/null || command -v batcat 2>/dev/null)
    if [ -z "$bat_cmd" ]; then
        return
    fi
    log_info "Rebuilding bat cache..."
    "$bat_cmd" cache --clear >/dev/null 2>&1 || true
    "$bat_cmd" cache --build >/dev/null 2>&1
    log_success "Bat cache rebuilt"
}

# JetBrains Mono Nerd Font (Linux only — macOS covered by update_homebrew)
update_nerd_font() {
    if [ "$(uname -s)" = "Darwin" ]; then
        return
    fi
    log_info "Checking JetBrains Mono Nerd Font..."
    local version
    version=$(curl -fsSL -o /dev/null -w "%{url_effective}" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    if [ -z "$version" ]; then
        log_warning "Could not determine Nerd Fonts version — skipping"
        return
    fi
    local font_dir="$HOME/.local/share/fonts/JetBrainsMono"
    local tmp_file
    tmp_file=$(mktemp --suffix=.tar.xz)
    curl -fsSL \
        "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/JetBrainsMono.tar.xz" \
        -o "$tmp_file" \
        || {
            log_warning "Failed to download JetBrains Mono Nerd Font"
            rm -f "$tmp_file"
            return
        }
    mkdir -p "$font_dir"
    tar -xJf "$tmp_file" -C "$font_dir" \
        || {
            log_warning "Failed to extract JetBrains Mono Nerd Font"
            rm -f "$tmp_file"
            return
        }
    rm -f "$tmp_file"
    fc-cache -fv >/dev/null 2>&1
    log_success "JetBrains Mono Nerd Font updated to v${version}"
}

# ─── Binary tool update helper ────────────────────────────────────────────────
#
# Updates a single GitHub/GitLab release binary in ~/.local/bin/.
# Silently skips if the binary is not there (it was likely installed by the
# system package manager and should be updated via apt/dnf/brew instead).
#
# Arguments:
#   $1  display name          e.g. "shfmt"
#   $2  binary filename       e.g. "shfmt"  (in ~/.local/bin/)
#   $3  version detection URL e.g. "https://github.com/owner/repo/releases/latest"
#   $4  download URL template — use {VERSION} (number, no v) and {ARCH} (uname -m)
#                               Prefix the path segment with v manually: "…/v{VERSION}/…"
#   $5  arch map (optional)   comma-separated "uname_arch:dl_arch" pairs
#                               e.g. "x86_64:amd64,aarch64:arm64"
#   $6  tarball binary name   if non-empty, the URL is a tar archive;
#                               extract the file with this name from it
#
_update_binary() {
    local name="$1" bin="$2" version_url="$3" url_tmpl="$4"
    local arch_map="${5:-}" extract="${6:-}"

    # Skip if not installed to ~/.local/bin/ (package-manager install — leave it alone)
    [ -f "$HOME/.local/bin/$bin" ] || return 0

    local arch
    arch=$(uname -m)

    # Apply optional architecture remapping
    if [ -n "$arch_map" ]; then
        local pair
        for pair in ${arch_map//,/ }; do
            if [ "${pair%%:*}" = "$arch" ]; then
                arch="${pair##*:}"
                break
            fi
        done
    fi

    local version
    version=$(curl -fsSL -o /dev/null -w "%{url_effective}" "$version_url" \
        | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    if [ -z "$version" ]; then
        log_warning "Could not determine $name version — skipping"
        return
    fi

    local url="${url_tmpl//\{VERSION\}/$version}"
    url="${url//\{ARCH\}/$arch}"

    if [ -n "$extract" ]; then
        local tmp
        tmp=$(mktemp -d)
        curl -fsSL "$url" -o "$tmp/archive" \
            || {
                log_warning "Failed to download $name"
                rm -rf "$tmp"
                return
            }
        tar -xf "$tmp/archive" -C "$tmp"
        local binary
        binary=$(find "$tmp" -name "$extract" -type f | head -1)
        if [ -z "$binary" ]; then
            log_warning "$name: binary '$extract' not found in archive"
            rm -rf "$tmp"
            return
        fi
        mv "$binary" "$HOME/.local/bin/$bin"
        rm -rf "$tmp"
    else
        curl -fsSL "$url" -o "$HOME/.local/bin/$bin" \
            || {
                log_warning "Failed to download $name"
                return
            }
    fi

    chmod +x "$HOME/.local/bin/$bin"
    log_success "$name updated to v${version}"
}

# GitHub release binaries installed to ~/.local/bin/ by install.sh
# (Linux only — macOS equivalents are Homebrew packages updated by update_homebrew)
update_binary_tools() {
    if [ "$(uname -s)" = "Darwin" ]; then
        return
    fi
    log_info "Updating GitHub release binaries in ~/.local/bin/..."

    # shfmt — shell formatter (uses amd64/arm64 arch names)
    _update_binary "shfmt" "shfmt" \
        "https://github.com/mvdan/sh/releases/latest" \
        "https://github.com/mvdan/sh/releases/download/v{VERSION}/shfmt_v{VERSION}_linux_{ARCH}" \
        "x86_64:amd64,aarch64:arm64"

    # lefthook — git hook runner
    _update_binary "lefthook" "lefthook" \
        "https://github.com/evilmartians/lefthook/releases/latest" \
        "https://github.com/evilmartians/lefthook/releases/download/v{VERSION}/lefthook_{VERSION}_Linux_{ARCH}" \
        "x86_64:x86_64,aarch64:arm64"

    # yq — YAML processor (uses amd64/arm64 arch names)
    _update_binary "yq" "yq" \
        "https://github.com/mikefarah/yq/releases/latest" \
        "https://github.com/mikefarah/yq/releases/download/v{VERSION}/yq_linux_{ARCH}" \
        "x86_64:amd64,aarch64:arm64"

    # eza — modern ls replacement (tarball, arch passes through as uname -m)
    _update_binary "eza" "eza" \
        "https://github.com/eza-community/eza/releases/latest" \
        "https://github.com/eza-community/eza/releases/download/v{VERSION}/eza_{ARCH}-unknown-linux-musl.tar.gz" \
        "" "eza"

    # git-cliff — changelog generator (tarball)
    _update_binary "git-cliff" "git-cliff" \
        "https://github.com/orhun/git-cliff/releases/latest" \
        "https://github.com/orhun/git-cliff/releases/download/v{VERSION}/git-cliff-{VERSION}-{ARCH}-unknown-linux-musl.tar.gz" \
        "" "git-cliff"

    # glab — GitLab CLI (tarball; hosted on gitlab.com, not github.com)
    _update_binary "glab" "glab" \
        "https://gitlab.com/gitlab-org/cli/-/releases/permalink/latest" \
        "https://gitlab.com/gitlab-org/cli/-/releases/v{VERSION}/downloads/glab_{VERSION}_Linux_{ARCH}.tar.gz" \
        "x86_64:x86_64,aarch64:arm64" "glab"
}

# ─── MAIN ─────────────────────────────────────────────────────────────────────

main() {
    echo "🔄 Dotfiles Update Script"
    echo "========================="

    if [[ $# -gt 0 ]]; then
        case "$1" in
            -h | --help)
                echo ""
                echo "Usage: $0 [STEP]"
                echo ""
                echo "Runs all steps when called with no arguments."
                echo "Pass a STEP name to run only that step."
                echo ""
                echo "Steps:"
                echo "  submodules   git submodule update --remote (oh-my-tmux, fzf-tab, zsh-fsh)"
                echo "  tpm          Update TPM plugins"
                echo "  homebrew     brew update / upgrade / bundle  (macOS only)"
                echo "  bat          Rebuild bat syntax/theme cache"
                echo "  nerd-font    Update JetBrains Mono Nerd Font  (Linux only)"
                echo "  binaries     Update GitHub release binaries in ~/.local/bin/  (Linux only)"
                exit 0
                ;;
            submodules)
                run_step "Git submodules" update_submodules
                exit $?
                ;;
            tpm)
                run_step "TPM plugins" update_tpm_plugins
                exit $?
                ;;
            homebrew)
                run_step "Homebrew" update_homebrew
                exit $?
                ;;
            bat)
                run_step "Bat cache" update_bat_cache
                exit $?
                ;;
            nerd-font)
                run_step "Nerd Font" update_nerd_font
                exit $?
                ;;
            binaries)
                run_step "Binary tools" update_binary_tools
                exit $?
                ;;
            *)
                log_error "Unknown step: $1"
                echo "Run '$0 --help' for available steps." >&2
                exit 1
                ;;
        esac
    fi

    # Run all steps in order — || true prevents set -e from aborting on a step failure;
    # run_step already logs the warning and returns 1 to signal the failure.
    local _failed=0
    run_step "Git submodules" update_submodules || _failed=1
    run_step "TPM plugins" update_tpm_plugins || _failed=1
    run_step "Homebrew" update_homebrew || _failed=1
    run_step "Bat cache" update_bat_cache || _failed=1
    run_step "Nerd Font" update_nerd_font || _failed=1
    run_step "Binary tools" update_binary_tools || _failed=1

    echo ""
    if [ "$_failed" -eq 0 ]; then
        log_success "All updates complete!"
    else
        log_warning "Some steps reported errors — see output above"
    fi
    echo ""
    echo "Restart your shell and any tmux sessions to pick up changes."
    echo '  Shell:   exec $SHELL'
    echo "  Plugins: prefix + I  (install new TPM plugins)"
}

main "$@"
