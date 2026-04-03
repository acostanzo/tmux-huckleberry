# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- Switch client before kill to stay in tmux when killing current session
- Last-session shortcut (`.`) in top-level dispatcher (#6)
- Top-level zoom shortcut (`z`) in dispatcher (#5)
- Space shortcut to fuzzy-find sessions from any sub-palette
- User-configurable extensions palette with `@huckleberry-extensions`
- Tab-to-select targeting for rename and kill actions
- New window and new pane actions
- Number hotkeys (1-9) for instant action selection in sub-palettes
- Resize pane action with direction sub-picker
- Toggles palette with live on/off state indicators
- Buffers palette with paste, choose, capture, delete, save
- Cross-session window search (find-window) and mark pane toggle
- Power-user actions across windows, panes, and config palettes
- List-clients and detach-client actions in session management
- Pane actions: zoom, rotate, display-numbers, clear-history, copy-mode, respawn, break, swap, kill, join, send
- Sessions management palette with rename, kill, create, detach-other-clients
- Panes palette with layout picker
- Windows and config sub-palettes
- Top-level command palette dispatcher with fzf category menu
- Session finder sub-palette with preview and Tab drill-down to window picker

### Fixed

- Number hotkeys capped at 9 to avoid fzf `--expect` error
- Path handling hardened with exact-match (`=`) tmux targets and resize UX
- Code review feedback addressed across palettes
- Startup speed optimized; Escape-to-go-back behavior added
- Security hardened: input validation, `=`-prefix on tmux targets
- `--` added before positional name args in rename-window
- Exit code 130 checked for text-input fzf escape handling
- Window rename persisted by disabling automatic-rename

### Changed

- Actions reordered by lifecycle (create first, kill last)
- Title Case headers, footer hints, and visual spacing added to palettes
- Popup title capitalized ("Huckleberry")
- Session palette extracted to module; shared common module created
