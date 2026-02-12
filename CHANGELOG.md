# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> **Note:** This changelog is automatically generated using [git-cliff](https://git-cliff.org/).
> To update: `git cliff --output CHANGELOG.md`

## [Unreleased]

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

---
[Unreleased]: https://github.com/robertlanier/dotfiles/commits/main

