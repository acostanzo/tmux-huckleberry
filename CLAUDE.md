# tmux-huckleberry

TPM-compatible fuzzy session switcher for tmux. Opens in a popup via `prefix + Space`; fuzzy-find an existing session or type a new name to create one.

## Architecture

1. `huckleberry.tmux` — TPM entry point; reads user options, binds key to open popup
2. `scripts/huckleberry.sh` — core palette logic; runs inside the popup, pipes sessions through fzf
3. `scripts/helpers.sh` — sourced utility (`get_tmux_option`)
4. `scripts/variables.sh` — sourced option-name constants and defaults

## File permissions

- **755** for executables: `huckleberry.tmux`, `scripts/huckleberry.sh`
- **644** for sourced files: `scripts/helpers.sh`, `scripts/variables.sh`

## Bash conventions

- Shebang: `#!/usr/bin/env bash`
- All files must pass `shellcheck` with zero warnings
- Quote all variable expansions (`"$var"`, `"${arr[@]}"`)
- Use `[[ ]]` for conditionals (not `[ ]`)
- Use `$(cmd)` for command substitution (not backticks)
- Resolve script directory via `BASH_SOURCE[0]`

## TPM conventions

- Entry point lives at the repo root and is named `*.tmux`
- User options use the `@huckleberry-` prefix
- Read options with `tmux show-option -gqv`

## Commit conventions

Conventional commits: `type(scope): description`

- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- Imperative mood, lowercase, no trailing period, under 72 characters
- Scope is optional but encouraged
