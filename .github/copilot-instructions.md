# Dotfiles Codebase Instructions

## Architecture: Base + Overlay Pattern

This is a **GNU Stow-based dotfiles manager** using a **layered configuration system** for cross-platform compatibility.

### Configuration Flow (Critical to understand)

```
~/.bashrc or ~/.zshrc (thin dispatchers)
  ↓
~/.config/shell/common.sh (cross-platform base)
  ↓
~/.config/shell/os/darwin.sh OR linux.sh (OS base)
  ↓
~/.config/shell/os/{ubuntu,fedora,rhel}.sh (distribution overlay)
  ↓
~/.config/shell/os/wsl.sh (WSL overlay, if applicable)
  ↓
~/.config/bash/.bashrc OR ~/.config/zsh/.zshrc (shell-specific configuration)
```

**Key principle**: Thin dispatchers in `~` that source layered configs in `~/.config`. Never put logic in the dispatchers—they only detect OS and source the appropriate files.

### Package Structure

Each top-level directory is a **stow package** (e.g., `shell/`, `bash/`, `zsh/`, `git/`). When stowed, symlinks are created from `$HOME` to files in the package. Files are organized to match their final destination:

```
bash/
├── .bashrc → symlinks to ~/.bashrc
├── .bash_profile → symlinks to ~/.bash_profile
└── .config/bash/ → symlinks to ~/.config/bash/
    ├── .bashrc
    └── .bash_profile

zsh/
├── .zshrc → symlinks to ~/.zshrc
├── .zprofile → symlinks to ~/.zprofile
└── .config/zsh/ → symlinks to ~/.config/zsh/
    └── ...

shell/
└── .config/shell/ → symlinks to ~/.config/shell/
    ├── common.sh
    └── os/
        ├── darwin.sh
        ├── linux.sh
        ├── ubuntu.sh
        └── wsl.sh
```

**Stow behavior**: `stow bash` creates symlinks in `$HOME` pointing back to files in `dotfiles/bash/`.

### OS Detection Logic

Located in [bash/.bashrc](bash/.bashrc) and [zsh/.zshrc](zsh/.zshrc):

1. Sources `/etc/os-release` to read `$ID` (ubuntu, fedora, rhel)
2. Loads configs in order: `common.sh` → OS base → distribution overlay → WSL (if detected)
3. Falls back to `uname -s` for macOS (Darwin)

**When adding new distribution support**: Create `shell/.config/shell/os/{distro}.sh` with distribution-specific configs. The dispatcher automatically loads it based on `$ID`.

## Developer Workflows

### Installation

```bash
./install.sh                    # Full install with deps + backup + deploy
./install.sh --deps-only        # Install tools only, no config deployment
./install.sh --skip-backup      # Deploy without backing up existing configs
```

**What install.sh does**:
1. Detects OS and distro from `/etc/os-release` or `uname`
2. Installs: git, stow, starship, zoxide, fzf, neovim, fastfetch
3. Backs up existing configs to `~/.dotfiles-backup-YYYYMMDD-HHMMSS/`
4. Runs `stow` for all packages: `shell bash zsh git starship fzf nvim vscode`
5. Creates `restore.sh` script in backup directory

### Rollback/Uninstallation

```bash
./uninstall.sh                  # Interactive backup selection
./uninstall.sh --auto           # Auto-select most recent backup
~/.dotfiles-backup-*/restore.sh # Direct restoration from backup
```

**How uninstall works**: 
1. Runs `stow -D` to remove symlinks
2. Restores files from timestamped backup directory

### Dual-Remote Git Workflow

This repo pushes to **GitLab (origin)** and **GitHub (github)** with different commit emails:

```bash
./push-both.sh main             # Push to both remotes
git push origin main            # GitLab only (robert.lanier@phreesia.com)
git push github main            # GitHub only (lanier@posteo.com)
```

**Implementation**: [push-both.sh](push-both.sh) temporarily sets `user.email` before each push, then restores default (GitLab email).

## Project-Specific Conventions

### File Naming Patterns

- **Thin dispatchers**: `.bashrc`, `.bash_profile`, `.zshrc`, `.zprofile` in package root (minimal logic, just source configs)
- **Real configs**: Inside `.config/` subdirectories (e.g., `.config/shell/common.sh`, `.config/bash/.bashrc`)
- **OS overlays**: Named after distribution ID from `/etc/os-release` (e.g., `ubuntu.sh`, `fedora.sh`)

### Stow Ignore Rules

See [.stow-local-ignore](.stow-local-ignore) - excludes:
- `.git`, `.gitignore`, `.DS_Store`
- `README.md`, documentation files
- `.stow-local-ignore` itself

**When adding files**: If a file shouldn't be symlinked to `$HOME`, add it to `.stow-local-ignore`.

### Shell Agnostic Design

Both bash and zsh use the same base configurations with shell-specific overlays:
- `bash/.bashrc` and `zsh/.zshrc` are nearly identical dispatchers
- Shared configs live in `shell/.config/shell/common.sh`
- Shell-specific configs in `.config/bash/` and `.config/zsh/`
- Each shell has its own stow package: `bash/` and `zsh/`

## Testing Changes

### Testing Configuration Changes

```bash
# After editing any .config/shell/ file:
exec $SHELL                     # Reload shell to test changes

# Test specific OS overlay without changing files:
source ~/.config/shell/os/ubuntu.sh
```

### Testing Installation

```bash
# Test in clean environment (VM or container recommended)
docker run -it ubuntu:latest bash
git clone <repo> && cd dotfiles
./install.sh
```

### Verifying Stow Symlinks

```bash
# Check what would be stowed (dry run)
stow -nv shell                  # -n = no-op, -v = verbose

# List actual symlinks created
ls -la ~ | grep ' -> '
ls -la ~/.config/ | grep ' -> '
```

## Common Modifications

### Adding a New OS Distribution

1. Create `shell/.config/shell/os/{distro-id}.sh` (use `$ID` from `/etc/os-release`)
2. Add distribution-specific paths, aliases, package managers
3. The dispatcher in `shell/.zshrc` will auto-load it

**Example**: See [shell/.config/shell/os/ubuntu.sh](shell/.config/shell/os/ubuntu.sh) for apt-specific configs.

### Adding a New Stow Package

1. Create directory: `mypackage/`
2. Mirror final destination structure: `mypackage/.config/myapp/config.toml`
3. Add package name to `PACKAGES_TO_STOW` in [install.sh](install.sh) line 16
4. Test: `stow mypackage` from dotfiles root

### Modifying Installation Dependencies

Edit [install.sh](install.sh) functions:
- `install_core_deps()` - Lines ~107-120: git, stow, zsh
- `install_starship()` - Lines ~123-130: Starship prompt
- `install_zoxide()` - Lines ~165-186: Smart cd
- `install_fzf()` - Lines ~189-206: Fuzzy finder

Each function has OS-specific branches for macOS (brew), Ubuntu (apt), Fedora/RHEL (dnf/yum).

## Architecture Decision Records

### Why Thin Dispatchers?

**Problem**: Keeping shell configs synchronized and avoiding duplication between shells.

**Solution**: Minimal dispatchers in `~` that only do OS detection and sourcing. All logic lives in `.config/`.

**Benefit**: Stow manages the dispatchers, but real configs can be edited without re-stowing. Each shell gets its own package for clarity.

### Why Separate linux.sh Base + Distribution Overlays?

**Problem**: Duplication between Ubuntu/Fedora/RHEL configs (90% identical, 10% different).

**Solution**: `linux.sh` contains shared Linux configs, distribution files only add/override specifics.

**Benefit**: Change base Linux behavior once; distribution overlays stay minimal.

### Why Dual Remotes?

**Context**: Work repos on GitLab (Phreesia email), personal repos on GitHub (personal email).

**Solution**: [push-both.sh](push-both.sh) handles email switching and pushes to both.

**Benefit**: One command syncs both remotes with correct email attribution for commits.
