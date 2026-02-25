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

Nine categories, one keypress away. Hit the hotkey to jump straight there, or type to fuzzy-search and press Enter.

| Key | Category | Description |
|---|---|---|
| `Space` | Find Session | Find, switch, create sessions |
| `s` | Sessions | Rename, kill, create, manage clients |
| `w` | Windows | Rename, kill, split, move, link windows |
| `p` | Panes | Zoom, resize, layout, swap, pipe, mark panes |
| `f` | Find Window | Search windows across all sessions |
| `b` | Buffers | Paste, capture, manage buffers |
| `t` | Toggles | Toggle tmux options on/off |
| `c` | Config | Reload config, browse keys, TPM |
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

Housekeeping for your sessions — rename, kill, create, or manage attached clients. Press **Tab** on rename or kill to pick a different target instead of the current session.

- **New session** — type a name to create and switch to a new session
- **Rename session** — Enter renames the current session; Tab opens a session picker first
- **List clients** — browse all attached clients (read-only)
- **Detach client** — pick a specific client to detach
- **Detach other clients** — detach all other clients from the current session
- **Kill session** — Enter kills the current session; Tab opens a session picker first

### Windows palette

Wrangle your windows without leaving the saddle. Press **Tab** on rename or kill to pick a different target instead of the current window.

- **New window** — create a new window (optionally named)
- **Rename window** — Enter renames the current window; Tab opens a window picker first
- **Split horizontal / vertical** — split the current pane
- **Move window left / right** — swap window position
- **Link window from session** — pick a session and window to link into the current session
- **Unlink window** — unlink the current window
- **Respawn window** — restart a dead/stuck window
- **Kill window** — Enter kills the current window; Tab opens a window picker first

### Panes palette

Rearrange the furniture. Layouts, swaps, moves, and the occasional eviction. Press **Tab** on rename or kill to pick a different target instead of the current pane.

- **New pane** — split the current window
- **Toggle zoom** — zoom/unzoom the current pane
- **Resize pane** — pick a direction (up/down/left/right) to resize by a configurable step
- **Select layout** — pick from 5 preset pane layouts
- **Swap pane** — swap current pane with another in the same window
- **Rotate panes** — cycle pane positions within the window
- **Send pane to window** — move current pane to another window
- **Join pane from window** — pull a pane from another window into this one
- **Break pane to window** — promote current pane to its own window
- **Enter copy mode** — enter copy mode in the current pane
- **Clear scrollback** — clear the current pane's scrollback buffer
- **Display pane numbers** — briefly show pane indices
- **Toggle mark** — mark/unmark the current pane (for swap/join operations)
- **Pipe pane to file** — start piping pane output to a file (empty path stops piping)
- **Respawn pane** — restart a dead/stuck pane
- **Rename pane** — Enter renames the current pane; Tab opens a pane picker first
- **Kill pane** — Enter kills the current pane; Tab opens a pane picker first

### Find Window palette

Search across your entire tmux estate. All windows from all sessions in one fuzzy-searchable list with a pane preview.

- **Type to filter** windows by session name, window name, or running command
- **Select a window** to switch directly to it
- Preview shows the pane list for the highlighted window

### Buffers palette

Clipboard and buffer management — paste, capture, browse, and save.

- **Paste buffer** — paste the most recent buffer
- **Choose buffer** — browse all buffers with a content preview, then paste the selected one
- **Capture pane to buffer** — capture the current pane's visible content
- **Delete buffer** — pick a buffer to delete
- **Save buffer to file** — type a file path to save the current buffer

### Toggles palette

Flip common tmux options on and off. The action list shows live `[on]`/`[off]` state indicators that update after each toggle.

- **Synchronized panes** — type to all panes simultaneously
- **Mouse mode** — enable/disable mouse support
- **Status bar** — show/hide the status bar
- **Pane border status** — show/hide pane border labels
- **Monitor activity** — enable/disable activity monitoring

### Config palette

Keep your setup in order without dropping to the command line.

- **Reload config** — re-sources your tmux.conf
- **TPM install plugins** — runs TPM install
- **TPM update plugins** — runs TPM update
- **Browse key bindings** — searchable read-only viewer of all tmux key bindings
- **Command prompt** — open the tmux command prompt

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
| `@huckleberry-cat-find-window-key` | `f` | Hotkey for Find Window category |
| `@huckleberry-cat-find-window-label` | `Find Window` | Display label for Find Window |
| `@huckleberry-cat-find-window-desc` | `Search windows across all sessions` | Description for Find Window |
| `@huckleberry-cat-buffers-key` | `b` | Hotkey for Buffers category |
| `@huckleberry-cat-buffers-label` | `Buffers` | Display label for Buffers |
| `@huckleberry-cat-buffers-desc` | `Paste, capture, manage buffers` | Description for Buffers |
| `@huckleberry-cat-toggles-key` | `t` | Hotkey for Toggles category |
| `@huckleberry-cat-toggles-label` | `Toggles` | Display label for Toggles |
| `@huckleberry-cat-toggles-desc` | `Toggle tmux options on/off` | Description for Toggles |
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
| `@huckleberry-ses-list-clients` | `List clients` | Label for list clients action |
| `@huckleberry-ses-list-clients-prompt` | `client > ` | fzf prompt for client browser |
| `@huckleberry-ses-list-clients-header` | `  Attached Clients (read-only)` | fzf header for client browser |
| `@huckleberry-ses-detach-client` | `Detach client` | Label for detach client action |
| `@huckleberry-ses-detach-client-prompt` | `client > ` | fzf prompt for client picker |
| `@huckleberry-ses-detach-client-header` | `  Detach Client` | fzf header for client picker |
| `@huckleberry-ses-detach` | `Detach other clients` | Label for detach all action |

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
| `@huckleberry-win-link` | `Link window from session` | Label for link window action |
| `@huckleberry-win-link-session-prompt` | `session > ` | fzf prompt for session picker (link) |
| `@huckleberry-win-link-session-header` | `  Link Window — Pick Session` | fzf header for session picker (link) |
| `@huckleberry-win-link-window-prompt` | `window > ` | fzf prompt for window picker (link) |
| `@huckleberry-win-link-window-header` | `  Link Window — Pick Window` | fzf header for window picker (link) |
| `@huckleberry-win-unlink` | `Unlink window` | Label for unlink window action |
| `@huckleberry-win-respawn` | `Respawn window` | Label for respawn window action |

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
| `@huckleberry-pane-zoom` | `Toggle zoom` | Label for zoom action |
| `@huckleberry-pane-resize` | `Resize pane` | Label for resize action |
| `@huckleberry-pane-resize-prompt` | `direction > ` | fzf prompt for direction picker |
| `@huckleberry-pane-resize-header` | `  Resize Pane` | fzf header for direction picker |
| `@huckleberry-pane-resize-step` | `5` | Number of cells per resize |
| `@huckleberry-pane-resize-up` | `Grow up` | Label for resize up |
| `@huckleberry-pane-resize-down` | `Grow down` | Label for resize down |
| `@huckleberry-pane-resize-left` | `Grow left` | Label for resize left |
| `@huckleberry-pane-resize-right` | `Grow right` | Label for resize right |
| `@huckleberry-pane-rotate` | `Rotate panes` | Label for rotate action |
| `@huckleberry-pane-display-numbers` | `Display pane numbers` | Label for display numbers action |
| `@huckleberry-pane-clear-history` | `Clear scrollback` | Label for clear history action |
| `@huckleberry-pane-copy-mode` | `Enter copy mode` | Label for copy mode action |
| `@huckleberry-pane-respawn` | `Respawn pane` | Label for respawn action |
| `@huckleberry-pane-mark` | `Toggle mark` | Label for mark pane action |
| `@huckleberry-pane-pipe` | `Pipe pane to file` | Label for pipe pane action |
| `@huckleberry-pane-pipe-prompt` | `path > ` | fzf prompt for pipe path input |
| `@huckleberry-pane-pipe-header` | `  Pipe Pane to File (empty to stop)` | fzf header for pipe path input |
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

### Find Window palette

| Option | Default | Description |
|---|---|---|
| `@huckleberry-find-window-prompt` | `window > ` | fzf prompt string |
| `@huckleberry-find-window-header` | `  Find Window` | fzf header text |
| `@huckleberry-find-window-footer` | `  esc back · enter switch` | fzf footer hint text |
| `@huckleberry-find-window-fmt` | *(see below)* | tmux format string for window list |
| `@huckleberry-find-window-preview` | `right:40%` | fzf preview window layout |
| `@huckleberry-find-window-preview-fmt` | *(see below)* | tmux format string for pane preview |

The default `@huckleberry-find-window-fmt` is:

```
#{session_name} > #{window_index}: #{window_name} [#{pane_current_command}]
```

The default `@huckleberry-find-window-preview-fmt` is:

```
#{pane_index}: #{pane_current_command} (#{pane_width}x#{pane_height})
```

### Buffers palette

| Option | Default | Description |
|---|---|---|
| `@huckleberry-buffers-prompt` | `buffer > ` | fzf prompt string |
| `@huckleberry-buffers-header` | `  Manage Buffers` | fzf header text |
| `@huckleberry-buffers-footer` | `  esc back` | fzf footer hint text |
| `@huckleberry-buf-paste` | `Paste buffer` | Label for paste action |
| `@huckleberry-buf-choose` | `Choose buffer` | Label for choose action |
| `@huckleberry-buf-choose-prompt` | `buffer > ` | fzf prompt for buffer picker |
| `@huckleberry-buf-choose-header` | `  Choose Buffer` | fzf header for buffer picker |
| `@huckleberry-buf-choose-preview` | `right:50%` | fzf preview layout for buffer contents |
| `@huckleberry-buf-capture` | `Capture pane to buffer` | Label for capture action |
| `@huckleberry-buf-delete` | `Delete buffer` | Label for delete action |
| `@huckleberry-buf-delete-prompt` | `buffer > ` | fzf prompt for delete picker |
| `@huckleberry-buf-delete-header` | `  Delete Buffer` | fzf header for delete picker |
| `@huckleberry-buf-save` | `Save buffer to file` | Label for save action |
| `@huckleberry-buf-save-prompt` | `path > ` | fzf prompt for save path input |
| `@huckleberry-buf-save-header` | `  Save Buffer to File` | fzf header for save path input |

### Toggles palette

| Option | Default | Description |
|---|---|---|
| `@huckleberry-toggles-prompt` | `toggle > ` | fzf prompt string |
| `@huckleberry-toggles-header` | `  Toggle Options` | fzf header text |
| `@huckleberry-toggles-footer` | `  esc back` | fzf footer hint text |
| `@huckleberry-toggle-on-indicator` | `[on]` | Text shown when a toggle is on |
| `@huckleberry-toggle-off-indicator` | `[off]` | Text shown when a toggle is off |
| `@huckleberry-toggle-sync-panes` | `Synchronized panes` | Label for sync panes toggle |
| `@huckleberry-toggle-mouse` | `Mouse mode` | Label for mouse toggle |
| `@huckleberry-toggle-status` | `Status bar` | Label for status bar toggle |
| `@huckleberry-toggle-pane-border` | `Pane border status` | Label for pane border toggle |
| `@huckleberry-toggle-monitor-activity` | `Monitor activity` | Label for monitor activity toggle |

### Config palette

| Option | Default | Description |
|---|---|---|
| `@huckleberry-config-prompt` | `config > ` | fzf prompt string |
| `@huckleberry-config-header` | `  Configuration` | fzf header text |
| `@huckleberry-config-footer` | `  esc back` | fzf footer hint text |
| `@huckleberry-cfg-reload` | `Reload config` | Label for reload action |
| `@huckleberry-cfg-tpm-install` | `TPM install plugins` | Label for TPM install |
| `@huckleberry-cfg-tpm-update` | `TPM update plugins` | Label for TPM update |
| `@huckleberry-cfg-browse-keys` | `Browse key bindings` | Label for browse keys action |
| `@huckleberry-cfg-browse-keys-prompt` | `key > ` | fzf prompt for key browser |
| `@huckleberry-cfg-browse-keys-header` | `  Key Bindings (read-only)` | fzf header for key browser |
| `@huckleberry-cfg-command-prompt` | `Command prompt` | Label for command prompt action |

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
