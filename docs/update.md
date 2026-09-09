# Updating

## Run All Updates

```bash
./update.sh
```

## Run a Single Step

```bash
./update.sh <step>
```

## Available Steps

| Step | What it updates | Platforms |
| ---- | --------------- | --------- |
| `submodules` | oh-my-tmux, fzf-tab, zsh-fsh to latest remote commits | All |
| `tpm` | All TPM plugins declared in `~/.tmux.conf.local` | All |
| `homebrew` | `brew update` + `brew upgrade` + `brew bundle` | macOS |
| `bat` | Bat syntax/theme cache | All |
| `nerd-font` | JetBrains Mono Nerd Font from GitHub releases | Linux |
| `binaries` | shfmt, lefthook, yq, eza, git-cliff, glab in `~/.local/bin/` | Linux |

The `binaries` step only acts on tools installed to `~/.local/bin/` — package-manager installs (apt, dnf) are unaffected.

## Adding a New Update Step

1. Write an `update_<name>()` function in `update.sh` under the `UPDATE STEPS` section.
2. Add one `run_step` line to `main()`:
   ```bash
   run_step "Display Name"  step-key  update_<name>
   ```
3. Add one `--help` entry for the new step key.

For new GitHub release binaries, the `_update_binary` helper handles both direct downloads and tarballs — see the existing `update_binary_tools` calls for the pattern.
