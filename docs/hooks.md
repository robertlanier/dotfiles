# Git Hooks (Lefthook)

## Setup

Run once after cloning to register hooks:

```bash
lefthook install
```

## Pre-commit Hooks

Defined in `lefthook.yml`. All hooks run against staged files only.

| Hook | Glob | What it does |
| ---- | ---- | ------------ |
| `check-merge-conflict` | all staged files | Fails if conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) are found |
| `shellcheck` | `*.sh`, `shell/**/*.sh`, `bash/.*`, `zsh/.*` | Lints shell files with ShellCheck |
| `shfmt` | `*.sh`, `shell/**/*.sh`, `bash/.*` | Formats shell files in-place |

## ShellCheck Configuration

`--shell=bash` is passed to ShellCheck for all staged files. This forces bash interpretation, which is correct for the shared config files sourced by both bash and zsh dispatchers.

Excluded codes — intentional for a cross-platform dotfiles repo:

| Code | Reason excluded |
| ---- | --------------- |
| SC1090 | `source` with dynamic/variable paths — expected throughout |
| SC1091 | Sourced file not found at check time — expected for stow-managed configs |
| SC2016 | Expressions in single quotes — intentional in many aliases |
| SC2148 | No shebang — expected for sourced config files |

## shfmt Configuration

- 4-space indent (`-i 4`)
- Binary operators on new lines (`-bn`)
- Indent `case` branches (`-ci`)
- Simplify where possible (`-s`)
- Writes in-place (`-w`)

## Running Hooks Manually

```bash
# Run all pre-commit hooks against staged files
lefthook run pre-commit

# Run a single hook
lefthook run pre-commit shellcheck
lefthook run pre-commit shfmt

# Check what would run without executing
lefthook run pre-commit --dry-run
```

## Skipping Hooks

Avoid using `--no-verify`. If a hook fails, investigate and fix the issue. The hooks exist to catch real problems.
