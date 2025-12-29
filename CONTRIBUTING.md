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

### Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples:**
```bash
feat(zsh): add fzf-tab plugin for better completion

fix(install): correct stow package order on macOS

docs(readme): update installation instructions for WSL
```

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
