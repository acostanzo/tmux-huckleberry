# tmux-huckleberry

TPM-compatible fuzzy command palette for tmux. Opens in a popup via `prefix + Space`; a top-level category menu routes to sub-palettes for sessions, windows, and config management.

## Architecture

```
[prefix + Space]
    ↓
scripts/huckleberry.sh (top-level dispatcher)
    ├─ ␣ Sessions → scripts/palettes/sessions.sh
    ├─ w Windows  → scripts/palettes/windows.sh
    └─ c Config   → scripts/palettes/config.sh
```

1. `huckleberry.tmux` — TPM entry point; reads user options, binds key to open popup
2. `scripts/huckleberry.sh` — top-level dispatcher; shows categories via fzf `--expect`, `exec`s into sub-palettes
3. `scripts/palettes/common.sh` — sourced shared infrastructure (path resolution, `strip_fzf_opts`)
4. `scripts/palettes/sessions.sh` — session switcher sub-palette (fuzzy-find/create sessions)
5. `scripts/palettes/windows.sh` — window management sub-palette (rename, split, move)
6. `scripts/palettes/config.sh` — config sub-palette (reload config, TPM install/update)
7. `scripts/helpers.sh` — sourced utility (`get_tmux_option`)
8. `scripts/variables.sh` — sourced option-name constants and defaults

## File permissions

- **755** for executables: `huckleberry.tmux`, `scripts/huckleberry.sh`, `scripts/palettes/sessions.sh`, `scripts/palettes/windows.sh`, `scripts/palettes/config.sh`
- **644** for sourced files: `scripts/helpers.sh`, `scripts/variables.sh`, `scripts/palettes/common.sh`

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

## Configurability

Every visual/stylistic choice exposed to the user must be configurable via a `@huckleberry-` tmux option. Never hardcode colors, labels, layout values, or display strings. For each option:
1. Add a constant and default to `scripts/variables.sh`
2. Read it via `get_tmux_option` in the appropriate script
3. Document it in the README configuration table with default and description

If a display property depends on the terminal or theme (e.g. border color), prefer relying on tmux's global settings rather than baking theme-specific values into the plugin.

## Commit conventions

Conventional commits: `type(scope): description`

- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- Imperative mood, lowercase, no trailing period, under 72 characters
- Scope is optional but encouraged
