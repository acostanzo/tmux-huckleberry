# tmux-huckleberry

TPM-compatible fuzzy command palette for tmux. Opens in a popup via `prefix + Space`; a top-level category menu routes to sub-palettes for sessions, windows, and config management.

## Architecture

```
[prefix + Space]
    ↓
scripts/huckleberry.sh (top-level dispatcher)
    ├─ ␣ Find Session → scripts/palettes/sessions.sh
    ├─ s Sessions     → scripts/palettes/session-mgmt.sh
    ├─ w Windows      → scripts/palettes/windows.sh
    ├─ p Panes        → scripts/palettes/panes.sh
    ├─ c Config       → scripts/palettes/config.sh
    └─ x Extensions   → scripts/palettes/extensions.sh (conditional)
```

1. `huckleberry.tmux` — TPM entry point; checks fzf dependency, reads user options, binds key to open popup
2. `scripts/huckleberry.sh` — top-level dispatcher; shows categories via fzf `--expect`, `source`s into sub-palettes
3. `scripts/palettes/common.sh` — sourced shared infrastructure (path resolution, conditional re-source guard)
4. `scripts/palettes/sessions.sh` — session finder sub-palette (fuzzy-find/create sessions)
5. `scripts/palettes/session-mgmt.sh` — session management sub-palette (rename, kill, create)
6. `scripts/palettes/windows.sh` — window management sub-palette (rename, split, move)
7. `scripts/palettes/panes.sh` — pane management sub-palette (layout, swap, move panes)
8. `scripts/palettes/config.sh` — config sub-palette (reload config, TPM install/update)
8b. `scripts/palettes/extensions.sh` — extensions sub-palette (user-configured extension commands; conditional)
9. `scripts/helpers.sh` — sourced utilities (`get_tmux_option`, `valid_session_name`, `strip_fzf_opts`)
10. `scripts/variables.sh` — sourced option-name constants and defaults

## File permissions

- **755** for executables: `huckleberry.tmux`, `scripts/huckleberry.sh`, `scripts/palettes/sessions.sh`, `scripts/palettes/session-mgmt.sh`, `scripts/palettes/windows.sh`, `scripts/palettes/panes.sh`, `scripts/palettes/config.sh`, `scripts/palettes/extensions.sh`
- **644** for sourced files: `scripts/helpers.sh`, `scripts/variables.sh`, `scripts/palettes/common.sh`

## Bash conventions

- Shebang: `#!/usr/bin/env bash`
- All files must pass `shellcheck -x` with zero warnings (suppress expected info-level codes inline)
- Quote all variable expansions (`"$var"`, `"${arr[@]}"`)
- Use `[[ ]]` for conditionals (not `[ ]`)
- Use `$(cmd)` for command substitution (not backticks)
- Resolve script directory via `BASH_SOURCE[0]`
- Prefer pure-bash builtins over external commands (avoid subshells where possible)
- Use `REPLY` variable pattern from `get_tmux_option` to avoid `$(...)` fork overhead
- Parse fzf `--print-query` output with `IFS= read -r` (not `| head -1`)
- All sub-palettes with multiple actions must use `while true` loops for consistent Escape-to-go-back

## Security

- Never interpolate fzf `{}` placeholder inside `$()` or backticks in `--preview` commands
- Use tmux `=` exact-match prefix on all `-t` target arguments (`-t "=$name"`)
- Validate session names via `valid_session_name` before `tmux new-session` or `tmux rename-session`

## TPM conventions

- Entry point lives at the repo root and is named `*.tmux`
- User options use the `@huckleberry-` prefix
- Read options via the `_huck_options_cache` mechanism in `helpers.sh`
- Check required dependencies (fzf) at plugin load time in `huckleberry.tmux`

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
