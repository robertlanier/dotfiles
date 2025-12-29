# Contributing to Dotfiles

Thank you for your interest in contributing! This document provides guidelines for contributing to this dotfiles repository.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally
3. **Create a branch** for your changes: `git checkout -b feature/your-feature-name`
4. **Make your changes** following the guidelines below
5. **Test your changes** thoroughly
6. **Commit your changes** with clear, descriptive messages
7. **Push to your fork** and submit a pull request

## Guidelines

### Code Style

- **Shell Scripts**: Follow the existing style in `.bashrc`, `.zshrc`, and `.config/shell/*.sh`
  - Use 4 spaces for indentation
  - Add comments explaining non-obvious logic
  - Use meaningful variable names
  - Quote variables: `"$var"` instead of `$var`

- **Documentation**:
  - Update README.md if adding new features
  - Add inline comments for complex configurations
  - Update `.github/copilot-instructions.md` for architectural changes
  - Changelog is auto-generated via git-cliff (don't edit manually)

### Commit Messages

This project follows [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) specification for automated changelog generation and semantic versioning.

#### Commit Message Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### Commit Types

| Type | Description | Changelog Section |
|------|-------------|-------------------|
| `feat` | New feature | Added |
| `fix` | Bug fix | Fixed |
| `docs` | Documentation only changes | Documentation |
| `style` | Code style changes (formatting, no logic change) | Styling |
| `refactor` | Code refactoring (no feature change or bug fix) | Changed |
| `perf` | Performance improvements | Performance |
| `test` | Adding or updating tests | Testing |
| `chore` | Build process, tooling, dependencies | Miscellaneous Tasks |
| `ci` | CI/CD pipeline changes | Miscellaneous Tasks |
| `revert` | Revert previous commit | Reverted |

#### Breaking Changes

Add `!` after type/scope or include `BREAKING CHANGE:` in footer:

```bash
feat!: redesign shell configuration architecture

BREAKING CHANGE: Previous shell configs are incompatible
```

#### Examples

**Feature:**
```bash
feat(zsh): add fzf-tab plugin for better completion
```

**Bug Fix:**
```bash
fix(install): correct stow package order on macOS
```

**Documentation:**
```bash
docs(readme): update installation instructions for WSL
```

**Refactor:**
```bash
refactor(bash): separate dispatchers into dedicated package
```

**Multiple Scopes:**
```bash
feat(zsh,bash): add shared OS detection logic
```

#### Scopes

Common scopes in this project:
- `bash` - Bash-specific changes
- `zsh` - Zsh-specific changes
- `shell` - Shared shell configuration
- `git` - Git configuration
- `nvim` - Neovim configuration
- `install` - Installation scripts
- `docs` - Documentation files

### Changelog Management

This project uses [git-cliff](https://git-cliff.org/) for automated changelog generation.

**Update changelog:**
```bash
# Generate changelog from all commits
git cliff --output CHANGELOG.md

# Preview without writing
git cliff

# Generate for specific version
git cliff --tag v2.0.0 --output CHANGELOG.md
```

**Note:** Don't edit `CHANGELOG.md` manually. All changes are derived from commit messages.

### Testing Changes

Before submitting:

1. **Test on your system**: Ensure changes work on your OS
2. **Check stow behavior**: Run `stow -nv package` to preview symlinks
3. **Verify installation**: Test `./install.sh` in a clean environment if possible
4. **Test uninstallation**: Ensure `./uninstall.sh` works correctly

### Adding OS Support

To add support for a new Linux distribution:

1. Create `shell/.config/shell/os/{distro-id}.sh` (use `$ID` from `/etc/os-release`)
2. Add distribution-specific configurations
3. Test installation on that distribution
4. Update README.md to list the new distribution
5. Update `.github/copilot-instructions.md` if the pattern changes

### Adding Stow Packages

1. Create directory: `mypackage/`
2. Mirror home directory structure: `mypackage/.config/myapp/config.toml`
3. Add package to `PACKAGES_TO_STOW` in `install.sh`
4. Add package to unstow commands in `uninstall.sh`
5. Document the package in README.md
6. Test with `stow -nv mypackage`

## Pull Request Process

1. **Update documentation** - README, comments, etc.
2. **Test thoroughly** - Ideally on multiple OSes
3. **Keep changes focused** - One feature per PR
4. **Describe your changes** - Explain what and why in the PR description
5. **Be responsive** - Address feedback in a timely manner

## Questions or Issues?

- Open an issue on GitHub for bugs or feature requests
- Check existing issues before creating new ones
- Provide detailed information: OS, shell version, error messages, etc.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
