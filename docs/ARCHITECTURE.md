# Architecture

tmux-huckleberry is a TPM-compatible command palette for tmux. It opens in a `display-popup` and uses fzf for fuzzy selection. The codebase is pure Bash (~13 files, no build step).

## Component Overview

```
huckleberry.tmux          TPM entry point
scripts/
  huckleberry.sh          Top-level dispatcher (main loop)
  helpers.sh              Shared utility functions
  variables.sh            Option constants and defaults (~155 options)
  palettes/
    common.sh             Sourced infrastructure (path resolution, re-source guard)
    sessions.sh           Session finder (fuzzy-find / create)
    session-mgmt.sh       Session management (rename, kill, create, clients)
    windows.sh            Window management (rename, split, move, link, respawn)
    panes.sh              Pane management (zoom, resize, layout, swap, pipe, mark)
    find-window.sh        Cross-session window search
    buffers.sh            Clipboard / buffer management
    toggles.sh            Toggle options with live [on]/[off] indicators
    config.sh             Config reload, key browser, TPM operations
    extensions.sh         User-configured extension commands (conditional)
```

## Startup Flow

1. **TPM loads `huckleberry.tmux`** — checks for fzf, reads user options from `@huckleberry-*` tmux options, binds `prefix + Space` to open a `display-popup` running `scripts/huckleberry.sh`.

2. **Dispatcher (`huckleberry.sh`)** — renders category menu via fzf with `--expect` for hotkey routing. On selection, `source`s the matching sub-palette script. On Escape, the popup closes.

3. **Sub-palettes** — each palette runs its own `while true` loop with fzf. Actions are numbered 1-9 for hotkey access. Escape returns to the dispatcher (via `return`, since palettes are `source`d, not exec'd).

## Key Design Patterns

### Options Cache

A single `tmux show-options -g` call is cached in `_huck_options_cache` at first use. All subsequent `get_tmux_option` calls scan this string instead of forking to tmux. The result is written to `$REPLY` (not captured via `$(...)`) to avoid subshell overhead.

### Source-Based Routing

The dispatcher `source`s sub-palettes rather than executing them. This means `return` goes back to the dispatcher's `while true` loop, while `exit` closes the popup entirely. This is how Escape-to-go-back works without process coordination.

### Action List Format

Actions use the `action_id::label` format. fzf displays only the label (`--with-nth 2`), while the ID is extracted after selection (`${line%%::*}`). Number prefixes (1-9) are prepended by `_huck_number_actions` in helpers.sh for hotkey display.

### Dynamic Menu Alignment

Menu labels are aligned with `printf '%-*s'` using a computed max label width. This keeps the description column neat regardless of label length or user overrides.

### Configurability

Every display string, key binding, prompt, header, footer, and visual property is exposed as a `@huckleberry-*` tmux option with a default in `variables.sh`. The plugin has zero hardcoded display values.

## Security Model

- **fzf `{}` isolation**: The `{}` placeholder in fzf `--preview` is never wrapped in `$()` or backticks, preventing command injection from session/window names.
- **Exact-match targets**: All tmux `-t` arguments use the `=` prefix (`-t "=$name"`) to prevent partial matching.
- **Session name validation**: `valid_session_name` rejects names containing `:` or `.` (tmux target delimiters) before any `new-session` or `rename-session` call.
