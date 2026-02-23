# :cowboy_hat_face: tmux-huckleberry

A quickdraw command palette for tmux — one keystroke opens a popup, you pick your shot, and you're there.

No memorizing obscure key sequences. No digging through man pages. Just `prefix + Space` and go.

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

Press **`prefix + Space`** to draw the command palette.

### Top-level menu

Five categories, one keypress away. Hit the hotkey to jump straight there, or type to fuzzy-search and press Enter.

| Key | Category | Description |
|---|---|---|
| `Space` | Find Session | Find, switch, create sessions |
| `s` | Sessions | Rename, kill, create sessions |
| `w` | Windows | Rename, kill, split, move windows |
| `p` | Panes | Rename, layout, swap, move panes |
| `c` | Config | Reload config, TPM install/update |
| `x` | Extensions | Run extension commands *(only shown when configured)* |

### Find Session palette

The fastest way to get where you're going. Type to narrow down your sessions, pick one to switch, or type a name that doesn't exist yet to create it on the spot.

- **Type to filter** existing sessions
- **Select a session** to switch to it
- **Press Tab** on a session to drill into its windows, then select a window to switch directly to it
- **Type a new name** and press Enter to create and switch to it
- Current session is marked with `*`
- Preview pane shows a clean window list with active marker, command, and pane count

### Sessions palette

Housekeeping for your sessions — rename, kill, create, or detach stale clients. Press **Tab** on rename or kill to pick a different target instead of the current session.

- **Rename session** — Enter renames the current session; Tab opens a session picker first
- **Kill session** — Enter kills the current session; Tab opens a session picker first
- **New session** — type a name to create and switch to a new session
- **Detach other clients** — detach all other clients from the current session

### Windows palette

Wrangle your windows without leaving the saddle. Press **Tab** on rename or kill to pick a different target instead of the current window.

- **Rename window** — Enter renames the current window; Tab opens a window picker first
- **Kill window** — Enter kills the current window; Tab opens a window picker first
- **Split horizontal / vertical** — split the current pane
- **Move window left / right** — swap window position

### Panes palette

Rearrange the furniture. Layouts, swaps, moves, and the occasional eviction. Press **Tab** on rename or kill to pick a different target instead of the current pane.

- **Rename pane** — Enter renames the current pane; Tab opens a pane picker first
- **Select layout** — pick from 5 preset pane layouts
- **Send pane to window** — move current pane to another window
- **Join pane from window** — pull a pane from another window into this one
- **Break pane to window** — promote current pane to its own window
- **Swap pane** — swap current pane with another in the same window
- **Kill pane** — Enter kills the current pane; Tab opens a pane picker first

### Config palette

Keep your setup in order without dropping to the command line.

- **Reload config** — re-sources your tmux.conf
- **TPM install plugins** — runs TPM install
- **TPM update plugins** — runs TPM update

### Extensions palette

Bring your own tmux plugins into the command palette. Define extensions and their actions through `@huckleberry-` options — the Extensions category only appears when you've configured at least one extension.

- **Select an extension** to see its available actions
- **Select an action** to run the configured tmux command
- **Escape** from actions returns to the extension list; Escape from the extension list returns to the top-level menu

#### Setting up extensions

Each extension needs an ID in the `@huckleberry-extensions` list and a set of actions. Here's tmux-resurrect as an example:

```bash
# Register extensions (comma-separated IDs)
set -g @huckleberry-extensions 'resurrect'

# Per-extension config: label, actions, and per-action label + command
set -g @huckleberry-extension-resurrect-label 'Resurrect'
set -g @huckleberry-extension-resurrect-actions 'save,restore'
set -g @huckleberry-extension-resurrect-save-label 'Save Session'
set -g @huckleberry-extension-resurrect-save-cmd 'run-shell ~/.config/tmux/plugins/tmux-resurrect/scripts/save.sh'
set -g @huckleberry-extension-resurrect-restore-label 'Restore Session'
set -g @huckleberry-extension-resurrect-restore-cmd 'run-shell ~/.config/tmux/plugins/tmux-resurrect/scripts/restore.sh'
```

The option naming pattern is:
- `@huckleberry-extension-<id>-label` — display name (defaults to the ID)
- `@huckleberry-extension-<id>-actions` — comma-separated action IDs
- `@huckleberry-extension-<id>-<action>-label` — action display name (defaults to the action ID)
- `@huckleberry-extension-<id>-<action>-cmd` — tmux command to run (passed to `tmux` as-is)

Keybinding hints are shown in the footer at the bottom of each palette.

Press **Escape** at any level to holster the popup and get back to work.

## Configuration

All options are set with `set -g` in your `~/.tmux.conf`. Every label, prompt, and display string is configurable — make it yours.

### Popup

| Option | Default | Description |
|---|---|---|
| `@huckleberry-bind` | `Space` | Key bound after prefix |
| `@huckleberry-width` | `60%` | Popup width |
| `@huckleberry-height` | `50%` | Popup height |
| `@huckleberry-x` | `C` | Popup horizontal position |
| `@huckleberry-y` | `C` | Popup vertical position |
| `@huckleberry-title` | ` 🤠 Huckleberry ` | Popup title bar text |
| `@huckleberry-border-lines` | `rounded` | Popup border style (`single`, `rounded`, `double`, `heavy`, `simple`, `padded`, `none`) |

### Top-level menu

| Option | Default | Description |
|---|---|---|
| `@huckleberry-menu-prompt` | `  ` | fzf prompt for category menu |
| `@huckleberry-menu-header` | `  Command Palette` | fzf header for category menu |
| `@huckleberry-menu-footer` | `  esc close` | fzf footer hint text |
| `@huckleberry-header-border` | `bottom` | fzf header border style (shared across palettes) |
| `@huckleberry-footer-border` | *(fzf default)* | fzf footer border style (shared across palettes) |
| `@huckleberry-space-display` | `␣` | Character shown for the space key |
| `@huckleberry-cat-sessions-key` | `space` | Hotkey for Find Session category |
| `@huckleberry-cat-sessions-label` | `Find Session` | Display label for Find Session |
| `@huckleberry-cat-sessions-desc` | `Find, switch, create sessions` | Description for Find Session |
| `@huckleberry-cat-session-mgmt-key` | `s` | Hotkey for Sessions category |
| `@huckleberry-cat-session-mgmt-label` | `Sessions` | Display label for Sessions |
| `@huckleberry-cat-session-mgmt-desc` | `Rename, kill, create sessions` | Description for Sessions |
| `@huckleberry-cat-windows-key` | `w` | Hotkey for Windows category |
| `@huckleberry-cat-windows-label` | `Windows` | Display label for Windows |
| `@huckleberry-cat-windows-desc` | `Rename, kill, split, move windows` | Description for Windows |
| `@huckleberry-cat-panes-key` | `p` | Hotkey for Panes category |
| `@huckleberry-cat-panes-label` | `Panes` | Display label for Panes |
| `@huckleberry-cat-panes-desc` | `Rename, layout, swap, move panes` | Description for Panes |
| `@huckleberry-cat-config-key` | `c` | Hotkey for Config category |
| `@huckleberry-cat-config-label` | `Config` | Display label for Config |
| `@huckleberry-cat-config-desc` | `Reload config, TPM install/update` | Description for Config |

### Find Session palette

| Option | Default | Description |
|---|---|---|
| `@huckleberry-prompt` | `session > ` | fzf prompt string |
| `@huckleberry-header` | `  Switch or Create a Session` | fzf header text |
| `@huckleberry-footer` | `  esc back · tab windows · enter switch` | fzf footer hint text |
| `@huckleberry-preview` | `right:50%` | fzf preview window layout |
| `@huckleberry-marker` | `* ` | Prefix for the current session |
| `@huckleberry-preview-fmt` | *(see below)* | tmux format string for preview window list |
| `@huckleberry-session-windows-prompt` | `window > ` | fzf prompt for the window picker |
| `@huckleberry-session-windows-header` | `  Select a Window` | fzf header for the window picker |
| `@huckleberry-session-windows-footer` | `  esc back · enter switch` | fzf footer for the window picker |
| `@huckleberry-session-windows-fmt` | *(see below)* | tmux format string for window picker list |

The default `@huckleberry-preview-fmt` is:

```
#{?window_active,  > ,    }#{window_index}: #{window_name} [#{pane_current_command}]#{?#{!=:#{window_panes},1}, (#{window_panes} panes),}
```

The default `@huckleberry-session-windows-fmt` is the same without the active marker:

```
#{window_index}: #{window_name} [#{pane_current_command}]#{?#{!=:#{window_panes},1}, (#{window_panes} panes),}
```

### Sessions palette

| Option | Default | Description |
|---|---|---|
| `@huckleberry-session-mgmt-prompt` | `session > ` | fzf prompt string |
| `@huckleberry-session-mgmt-header` | `  Manage Sessions` | fzf header text |
| `@huckleberry-session-mgmt-footer` | `  esc back · tab pick target` | fzf footer hint text |
| `@huckleberry-ses-rename` | `Rename session` | Label for rename action |
| `@huckleberry-ses-rename-prompt` | `name > ` | fzf prompt for rename input |
| `@huckleberry-ses-rename-header` | `  Rename Session` | fzf header for rename input |
| `@huckleberry-ses-rename-pick-prompt` | `session > ` | fzf prompt for Tab session picker (rename) |
| `@huckleberry-ses-rename-pick-header` | `  Rename Session` | fzf header for Tab session picker (rename) |
| `@huckleberry-ses-kill` | `Kill session` | Label for kill action |
| `@huckleberry-ses-kill-prompt` | `session > ` | fzf prompt for Tab session picker (kill) |
| `@huckleberry-ses-kill-header` | `  Kill Session` | fzf header for Tab session picker (kill) |
| `@huckleberry-ses-new` | `New session` | Label for new session action |
| `@huckleberry-ses-new-prompt` | `name > ` | fzf prompt for new session input |
| `@huckleberry-ses-new-header` | `  Create Session` | fzf header for new session input |
| `@huckleberry-ses-detach` | `Detach other clients` | Label for detach action |

### Windows palette

| Option | Default | Description |
|---|---|---|
| `@huckleberry-windows-prompt` | `window > ` | fzf prompt string |
| `@huckleberry-windows-header` | `  Manage Windows` | fzf header text |
| `@huckleberry-windows-footer` | `  esc back · tab pick target` | fzf footer hint text |
| `@huckleberry-win-rename` | `Rename window` | Label for rename action |
| `@huckleberry-win-rename-prompt` | `name > ` | fzf prompt for rename input |
| `@huckleberry-win-rename-header` | `  Rename Window` | fzf header for rename input |
| `@huckleberry-win-rename-pick-prompt` | `window > ` | fzf prompt for Tab window picker (rename) |
| `@huckleberry-win-rename-pick-header` | `  Rename Window` | fzf header for Tab window picker (rename) |
| `@huckleberry-win-kill` | `Kill window` | Label for kill action |
| `@huckleberry-win-kill-pick-prompt` | `window > ` | fzf prompt for Tab window picker (kill) |
| `@huckleberry-win-kill-pick-header` | `  Kill Window` | fzf header for Tab window picker (kill) |
| `@huckleberry-win-split-h` | `Split horizontal` | Label for horizontal split |
| `@huckleberry-win-split-v` | `Split vertical` | Label for vertical split |
| `@huckleberry-win-move-left` | `Move window left` | Label for move left |
| `@huckleberry-win-move-right` | `Move window right` | Label for move right |

### Panes palette

| Option | Default | Description |
|---|---|---|
| `@huckleberry-panes-prompt` | `pane > ` | fzf prompt string |
| `@huckleberry-panes-header` | `  Manage Panes` | fzf header text |
| `@huckleberry-panes-footer` | `  esc back · tab pick target` | fzf footer hint text |
| `@huckleberry-pane-rename` | `Rename pane` | Label for rename action |
| `@huckleberry-pane-rename-prompt` | `title > ` | fzf prompt for rename input |
| `@huckleberry-pane-rename-header` | `  Rename Pane` | fzf header for rename input |
| `@huckleberry-pane-rename-pick-prompt` | `pane > ` | fzf prompt for Tab pane picker (rename) |
| `@huckleberry-pane-rename-pick-header` | `  Rename Pane` | fzf header for Tab pane picker (rename) |
| `@huckleberry-pane-select-layout` | `Select layout` | Label for select layout action |
| `@huckleberry-pane-layout-prompt` | `layout > ` | fzf prompt for layout picker |
| `@huckleberry-pane-layout-header` | `  Select Layout` | fzf header for layout picker |
| `@huckleberry-pane-layout-even-h` | `Even horizontal` | Label for even-horizontal layout |
| `@huckleberry-pane-layout-even-v` | `Even vertical` | Label for even-vertical layout |
| `@huckleberry-pane-layout-main-h` | `Main horizontal` | Label for main-horizontal layout |
| `@huckleberry-pane-layout-main-v` | `Main vertical` | Label for main-vertical layout |
| `@huckleberry-pane-layout-tiled` | `Tiled` | Label for tiled layout |
| `@huckleberry-pane-send` | `Send pane to window` | Label for send pane action |
| `@huckleberry-pane-send-prompt` | `window > ` | fzf prompt for window picker |
| `@huckleberry-pane-send-header` | `  Send Pane to Window` | fzf header for window picker |
| `@huckleberry-pane-join` | `Join pane from window` | Label for join pane action |
| `@huckleberry-pane-join-prompt` | `pane > ` | fzf prompt for pane picker |
| `@huckleberry-pane-join-header` | `  Join Pane from Window` | fzf header for pane picker |
| `@huckleberry-pane-break` | `Break pane to window` | Label for break pane action |
| `@huckleberry-pane-swap` | `Swap pane` | Label for swap pane action |
| `@huckleberry-pane-swap-prompt` | `pane > ` | fzf prompt for swap picker |
| `@huckleberry-pane-swap-header` | `  Swap Pane` | fzf header for swap picker |
| `@huckleberry-pane-kill` | `Kill pane` | Label for kill pane action |
| `@huckleberry-pane-kill-pick-prompt` | `pane > ` | fzf prompt for Tab pane picker (kill) |
| `@huckleberry-pane-kill-pick-header` | `  Kill Pane` | fzf header for Tab pane picker (kill) |

### Config palette

| Option | Default | Description |
|---|---|---|
| `@huckleberry-config-prompt` | `config > ` | fzf prompt string |
| `@huckleberry-config-header` | `  Configuration` | fzf header text |
| `@huckleberry-config-footer` | `  esc back` | fzf footer hint text |
| `@huckleberry-cfg-reload` | `Reload config` | Label for reload action |
| `@huckleberry-cfg-tpm-install` | `TPM install plugins` | Label for TPM install |
| `@huckleberry-cfg-tpm-update` | `TPM update plugins` | Label for TPM update |

### Extensions palette

| Option | Default | Description |
|---|---|---|
| `@huckleberry-cat-extensions-key` | `x` | Hotkey for Extensions category |
| `@huckleberry-cat-extensions-label` | `Extensions` | Display label for Extensions |
| `@huckleberry-cat-extensions-desc` | `Run extension commands` | Description for Extensions |
| `@huckleberry-extensions` | *(empty)* | Comma-separated extension IDs (empty = hidden) |
| `@huckleberry-extensions-prompt` | `extension > ` | fzf prompt for extension list |
| `@huckleberry-extensions-header` | `  Extensions` | fzf header for extension list |
| `@huckleberry-extensions-footer` | `  esc back` | fzf footer for extension list |
| `@huckleberry-extensions-actions-prompt` | `action > ` | fzf prompt for action list |
| `@huckleberry-extensions-actions-header-prefix` | `  ` | Prefix before extension name in action header |
| `@huckleberry-extensions-actions-footer` | `  esc back` | fzf footer for action list |

Per-extension options use dynamic names constructed from the extension and action IDs:

| Pattern | Description |
|---|---|
| `@huckleberry-extension-<id>-label` | Display name for the extension (defaults to ID) |
| `@huckleberry-extension-<id>-actions` | Comma-separated action IDs |
| `@huckleberry-extension-<id>-<action>-label` | Display name for the action (defaults to action ID) |
| `@huckleberry-extension-<id>-<action>-cmd` | tmux command to execute |

### Example

```bash
set -g @huckleberry-bind 'S'
set -g @huckleberry-width '80%'
set -g @huckleberry-height '60%'
set -g @huckleberry-menu-header '  Pick a Category'
set -g @huckleberry-cat-sessions-key 's'
```

## License

[MIT](LICENSE)
