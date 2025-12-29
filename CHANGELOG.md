# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> **Note:** This changelog is automatically generated using [git-cliff](https://git-cliff.org/).
> To update: `git cliff --output CHANGELOG.md`

## [Unreleased]

### Added

- MIT License
- Contributing guidelines with Conventional Commits specification
- EditorConfig for consistent code formatting
- Changelog tracking with git-cliff automation
- Comprehensive table of contents in README

### Changed

- README.md: Removed emojis for professional appearance
- README.md: Improved structure and readability

## [1.0.0] - 2025-12-29

### Added
- GNU Stow-based dotfiles management
- Cross-platform support (macOS, Linux, WSL)
- Base + overlay architecture for OS-specific configs
- Automatic OS detection for Linux distributions
- Separate bash and zsh packages with thin dispatchers
- Shared shell configuration in `shell/` package
- Dual-remote git workflow (GitLab + GitHub)
- Automated installation script with dependency management
- Backup and restore functionality
- Starship prompt configuration
- Zoxide (smart cd) integration
- FZF fuzzy finder configuration
- Neovim configuration
- VS Code settings synchronization

### Changed
- Refactored shell structure: separated bash and zsh into dedicated packages
- Standardized on neovim, removed vim package
- Cleaned up shell package to only contain shared configs

### Fixed
- Stow ignore patterns for .DS_Store files
- Git config merge conflicts during rebase

## [0.1.0] - Initial Release

### Added
- Basic dotfiles structure
- Initial shell configurations
- Git configuration

---

[Unreleased]: https://github.com/robertlanier/dotfiles/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/robertlanier/dotfiles/releases/tag/v1.0.0
[0.1.0]: https://github.com/robertlanier/dotfiles/releases/tag/v0.1.0
