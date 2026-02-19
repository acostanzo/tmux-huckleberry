# tmux-huckleberry

Fuzzy command palette for tmux — open a popup, pick a category, then fuzzy-find an action.

## Requirements

- tmux >= 3.2 (for `display-popup`)
- [fzf](https://github.com/junegunn/fzf)
- [TPM](https://github.com/tmux-plugins/tpm)

## Installation

Add to your `~/.tmux.conf`:

```bash
set -g @plugin 'acostanzo/tmux-huckleberry'
```

Then press `prefix + I` to install via TPM.

## Usage

Press **`prefix + Space`** to open the command palette.

### Top-level menu

The palette opens with three categories. Press the hotkey to jump instantly, or type to fuzzy-search and press Enter.

| Key | Category | Description |
|---|---|---|
| `Space` | Sessions | Switch or create sessions |
| `w` | Windows | Rename, split, move windows |
| `c` | Config | Reload config, TPM install/update |

### Sessions palette

- **Type to filter** existing sessions
- **Select a session** to switch to it
- **Type a new name** and press Enter to create and switch to it
- Current session is marked with `*`

### Windows palette

- **Rename window** — opens tmux's native rename prompt
- **Split horizontal / vertical** — split the current pane
- **Move window left / right** — swap window position

### Config palette

- **Reload config** — re-sources your tmux.conf
- **TPM install plugins** — runs TPM install
- **TPM update plugins** — runs TPM update

Press **Escape** at any level to dismiss the popup.

## Configuration

All options are set with `set -g` in your `~/.tmux.conf`.

### Popup

| Option | Default | Description |
|---|---|---|
| `@huckleberry-bind` | `Space` | Key bound after prefix |
| `@huckleberry-width` | `60%` | Popup width |
| `@huckleberry-height` | `50%` | Popup height |
| `@huckleberry-x` | `C` | Popup horizontal position |
| `@huckleberry-y` | `C` | Popup vertical position |
| `@huckleberry-title` | ` 🤠 huckleberry ` | Popup title bar text |
| `@huckleberry-border-lines` | `rounded` | Popup border style (`single`, `rounded`, `double`, `heavy`, `simple`, `padded`, `none`) |

### Top-level menu

| Option | Default | Description |
|---|---|---|
| `@huckleberry-menu-prompt` | `  ` | fzf prompt for category menu |
| `@huckleberry-menu-header` | `command palette` | fzf header for category menu |
| `@huckleberry-space-display` | `␣` | Character shown for the space key |
| `@huckleberry-cat-sessions-key` | `space` | Hotkey for Sessions category |
| `@huckleberry-cat-sessions-label` | `Sessions` | Display label for Sessions |
| `@huckleberry-cat-sessions-desc` | `Switch or create sessions` | Description for Sessions |
| `@huckleberry-cat-windows-key` | `w` | Hotkey for Windows category |
| `@huckleberry-cat-windows-label` | `Windows` | Display label for Windows |
| `@huckleberry-cat-windows-desc` | `Rename, split, move windows` | Description for Windows |
| `@huckleberry-cat-config-key` | `c` | Hotkey for Config category |
| `@huckleberry-cat-config-label` | `Config` | Display label for Config |
| `@huckleberry-cat-config-desc` | `Reload config, TPM install/update` | Description for Config |

### Sessions palette

| Option | Default | Description |
|---|---|---|
| `@huckleberry-prompt` | `session > ` | fzf prompt string |
| `@huckleberry-header` | `  switch or create a session` | fzf header text |
| `@huckleberry-preview` | `right:50%` | fzf preview window layout |
| `@huckleberry-marker` | `* ` | Prefix for the current session |

### Windows palette

| Option | Default | Description |
|---|---|---|
| `@huckleberry-windows-prompt` | `window > ` | fzf prompt string |
| `@huckleberry-windows-header` | `  pick a window action` | fzf header text |
| `@huckleberry-win-rename` | `Rename window` | Label for rename action |
| `@huckleberry-win-split-h` | `Split horizontal` | Label for horizontal split |
| `@huckleberry-win-split-v` | `Split vertical` | Label for vertical split |
| `@huckleberry-win-move-left` | `Move window left` | Label for move left |
| `@huckleberry-win-move-right` | `Move window right` | Label for move right |

### Config palette

| Option | Default | Description |
|---|---|---|
| `@huckleberry-config-prompt` | `config > ` | fzf prompt string |
| `@huckleberry-config-header` | `  pick a config action` | fzf header text |
| `@huckleberry-cfg-reload` | `Reload config` | Label for reload action |
| `@huckleberry-cfg-tpm-install` | `TPM install plugins` | Label for TPM install |
| `@huckleberry-cfg-tpm-update` | `TPM update plugins` | Label for TPM update |

### Example

```bash
set -g @huckleberry-bind 'S'
set -g @huckleberry-width '80%'
set -g @huckleberry-height '60%'
set -g @huckleberry-menu-header 'pick a category'
set -g @huckleberry-cat-sessions-key 's'
```

## License

[MIT](LICENSE)
