# Quick Reference

## Setup

```bash
./install.sh                    # Full install (deps + backup + deploy)
./install.sh --deps-only        # Install tools only
./install.sh --skip-backup      # Deploy without backup or restore prompt
./install.sh --skip-deploy      # Install tools only, do not deploy configs
./update.sh                     # Run all updates
./update.sh <step>              # Run one step (submodules | tpm | homebrew | bat | nerd-font | binaries)
./uninstall.sh                  # Interactive uninstall + restore
./uninstall.sh --auto           # Auto-select most recent backup
```

## Stow

```bash
stow -nv <package>                          # Dry-run (preview symlinks)
stow shell bash zsh git starship fzf nvim bat tmux   # Deploy all packages
stow -R <package>                           # Restow a single package
stow -D <package>                           # Remove a package's symlinks
```

## Git Submodules

```bash
git submodule update --init --recursive     # After clone: populate all submodules
git submodule update --remote --merge       # Update all submodules to latest upstream
git submodule update --remote tmux-ohmytmux # Update oh-my-tmux only
```

## Git Hooks

```bash
lefthook install                            # Register hooks after clone
lefthook run pre-commit                     # Run all pre-commit hooks manually
lefthook run pre-commit shellcheck          # Run shellcheck hook only
lefthook run pre-commit shfmt               # Run shfmt hook only
```

## Tmux / TPM

```bash
~/.tmux/plugins/tpm/bin/install_plugins    # Install all declared plugins
~/.tmux/plugins/tpm/bin/update_plugins all # Update all installed plugins
```

Inside tmux (prefix = `ctrl-a`):

| Keys | Action |
| ---- | ------ |
| `prefix I` | Install new TPM plugins |
| `prefix U` | Update TPM plugins |
| `prefix r` | Reload tmux config |
| `prefix e` | Edit `~/.tmux.conf.local` |
| `prefix m` | Toggle mouse |

## Bat

```bash
bat cache --clear && bat cache --build      # Rebuild syntax/theme cache
```

## ShellCheck (manual)

```bash
shellcheck --shell=bash -x -S warning --exclude=SC1090,SC1091,SC2016,SC2148 <file>
```

## shfmt (manual)

```bash
shfmt -w -s -i 4 -bn -ci <file>
```
