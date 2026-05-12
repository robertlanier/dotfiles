# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> **Note:** This changelog is automatically generated using [git-cliff](https://git-cliff.org/).
> To update: `git cliff --output CHANGELOG.md`

## [1.0.4] - 2026-05-12

### Fixed

- **starship**: Use 24-hour time format

## [1.0.3] - 2026-05-12

### Fixed

- **vscode**: Use glob pattern for stow-local-ignore file association

## [1.0.2] - 2026-05-12

### Fixed

- **vscode**: Improve workspace settings and stow ignore

## [1.0.1] - 2026-05-12

### Added

- Add cross-platform OS detection and dual-remote push script
- Add comprehensive WSL support with Windows interop
- Add bash support and neovim package, remove aliases
- Add automated installation script for all platforms
- Add complete automation for install/backup/restore workflow
- **docs**: Add git-cliff for automated changelog generation
- **xdg**: Implement full XDG Base Directory compliance
- Add delta pager with Catppuccin theme and bat stow package
- Added new cli tools
- Added ble.sh line within .bashrc
- **git**: Enabled rebase autostash
- **shell**: Add machine-local override hook
- **starship**: Add ADHD-optimized two-line prompt format

### Changed

- Improve OS detection with base + overlay pattern
- Simplify WSL config - remove unused aliases and shortcuts
- Remove Docker Desktop integration from WSL config
- Separate bash and zsh into dedicated packages
- Remove vim, standardize on neovim

### Documentation

- Update README with current architecture and OS detection
- Update README with WSL support and Windows clarification
- Add professional project standards and documentation
- Remove emojis and improve table of contents

### Fixed

- Rebase confit with git config
- Add .DS_Store to ignore and reorganized the file
- Added complete installation of direnv
- Removed hostname to fix rhel 9 issue
- Ran precommit and fixed issues
- Removed ble.sh
- **fzf**: Vendor catppuccin theme fiels instead of broken gitlink
- **shell**: Added local paths and auto ssh start:
- **bash**: Remove stale comment and cc() launcher function
- **zsh**: Resolve FSH ordering bug, history conflict, and brew caching
- **git**: Replace hardcoded GCM path with portable helper
- **shell**: Move SSH agent to linux.sh and fix redirect and XDG_RUNTIME_DIR bugs
- **ci**: Add document start and expand shellcheck args to block sequence

### Miscellaneous Tasks

- Ignore OS junk and zsh session state
- Untrack zsh session/history; add .gitignore rules
- Added SRC env variable and updated README
- **wsl**: Removed ssh aliases and core.sshCommand
- **changelog**: Regenerate with git-cliff and fix template
- Simplify dotfiles repo setup
- Clean up workspace
- Modified starship prompt
- **documentation**: Removed dual remote section of README
- **README**: Fixed markdown linting errors
- Updated changelog
- Updated CHANGELOG.md
- Removed hostname and username from ssh prompt
- Disabled hostname in prompt
- **starship**: Removed 'is' from package format

### Choare

- **fzf**: Removed bloat from theme directory

---
[Unreleased]: https://github.com/robertlanier/dotfiles/commits/main

