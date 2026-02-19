# tmux-huckleberry

Fuzzy session switcher for tmux — open a popup, pick a session or create a new one.

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

Press **`prefix + Space`** to open the session palette.

- **Type to filter** existing sessions
- **Select a session** to switch to it
- **Type a new name** and press Enter to create and switch to it
- **Escape** to dismiss

The current session is marked with `*`.

## Configuration

All options are set with `set -g` in your `~/.tmux.conf`:

| Option | Default | Description |
|---|---|---|
| `@huckleberry-bind` | `Space` | Key bound after prefix |
| `@huckleberry-width` | `60%` | Popup width |
| `@huckleberry-height` | `50%` | Popup height |
| `@huckleberry-x` | `C` | Popup horizontal position |
| `@huckleberry-y` | `C` | Popup vertical position |
| `@huckleberry-title` | ` 🤠 huckleberry ` | Popup title bar text |
| `@huckleberry-prompt` | `session > ` | fzf prompt string |

### Example

```bash
set -g @huckleberry-bind 'S'
set -g @huckleberry-width '80%'
set -g @huckleberry-height '60%'
set -g @huckleberry-prompt 'switch > '
```

## License

[MIT](LICENSE)
