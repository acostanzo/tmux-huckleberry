#!/usr/bin/env bash
# Option names and their default values.
# Sourced by huckleberry.tmux and scripts/huckleberry.sh.
# shellcheck disable=SC2034  # variables are used by sourcing scripts

# Key binding (added after prefix)
HUCKLEBERRY_BIND="@huckleberry-bind"
HUCKLEBERRY_BIND_DEFAULT="Space"

# Popup dimensions
HUCKLEBERRY_WIDTH="@huckleberry-width"
HUCKLEBERRY_WIDTH_DEFAULT="60%"

HUCKLEBERRY_HEIGHT="@huckleberry-height"
HUCKLEBERRY_HEIGHT_DEFAULT="50%"

# Popup position
HUCKLEBERRY_X="@huckleberry-x"
HUCKLEBERRY_X_DEFAULT="C"

HUCKLEBERRY_Y="@huckleberry-y"
HUCKLEBERRY_Y_DEFAULT="C"

# Popup title
HUCKLEBERRY_TITLE="@huckleberry-title"
HUCKLEBERRY_TITLE_DEFAULT=" 🤠 Huckleberry "

# Popup border line style (single, rounded, double, heavy, simple, padded, none)
HUCKLEBERRY_BORDER_LINES="@huckleberry-border-lines"
HUCKLEBERRY_BORDER_LINES_DEFAULT="rounded"

# fzf prompt string
HUCKLEBERRY_PROMPT="@huckleberry-prompt"
HUCKLEBERRY_PROMPT_DEFAULT="session > "

# fzf header text
HUCKLEBERRY_HEADER="@huckleberry-header"
HUCKLEBERRY_HEADER_DEFAULT="  Switch or Create a Session"

# fzf preview window layout
HUCKLEBERRY_PREVIEW="@huckleberry-preview"
HUCKLEBERRY_PREVIEW_DEFAULT="right:50%"

# Current session marker prefix
HUCKLEBERRY_MARKER="@huckleberry-marker"
HUCKLEBERRY_MARKER_DEFAULT="* "

# Preview format for session window list
HUCKLEBERRY_PREVIEW_FMT="@huckleberry-preview-fmt"
HUCKLEBERRY_PREVIEW_FMT_DEFAULT='#{?window_active,  > ,    }#{window_index}: #{window_name} [#{pane_current_command}]#{?#{!=:#{window_panes},1}, (#{window_panes} panes),}'

# Nested window picker (shown after Tab on a session)
HUCKLEBERRY_SESSION_WINDOWS_PROMPT="@huckleberry-session-windows-prompt"
HUCKLEBERRY_SESSION_WINDOWS_PROMPT_DEFAULT="window > "

HUCKLEBERRY_SESSION_WINDOWS_HEADER="@huckleberry-session-windows-header"
HUCKLEBERRY_SESSION_WINDOWS_HEADER_DEFAULT="  Select a Window"

HUCKLEBERRY_SESSION_WINDOWS_FMT="@huckleberry-session-windows-fmt"
HUCKLEBERRY_SESSION_WINDOWS_FMT_DEFAULT='#{window_index}: #{window_name} [#{pane_current_command}]#{?#{!=:#{window_panes},1}, (#{window_panes} panes),}'

# ---------------------------------------------------------------------------
# Shared layout options
# ---------------------------------------------------------------------------

# fzf header border style (applied to --header-border; empty = fzf default)
HUCKLEBERRY_HEADER_BORDER="@huckleberry-header-border"
HUCKLEBERRY_HEADER_BORDER_DEFAULT="bottom"

# fzf footer border style (applied to --footer-border; empty = fzf default "line")
HUCKLEBERRY_FOOTER_BORDER="@huckleberry-footer-border"
HUCKLEBERRY_FOOTER_BORDER_DEFAULT=""

# Per-palette footer text
HUCKLEBERRY_FOOTER="@huckleberry-footer"
HUCKLEBERRY_FOOTER_DEFAULT="  esc back · tab windows · enter switch"

HUCKLEBERRY_SESSION_WINDOWS_FOOTER="@huckleberry-session-windows-footer"
HUCKLEBERRY_SESSION_WINDOWS_FOOTER_DEFAULT="  esc back · enter switch"

# ---------------------------------------------------------------------------
# Top-level menu
# ---------------------------------------------------------------------------

HUCKLEBERRY_MENU_PROMPT="@huckleberry-menu-prompt"
HUCKLEBERRY_MENU_PROMPT_DEFAULT="  "

HUCKLEBERRY_MENU_HEADER="@huckleberry-menu-header"
HUCKLEBERRY_MENU_HEADER_DEFAULT="  Command Palette"

HUCKLEBERRY_MENU_FOOTER="@huckleberry-menu-footer"
HUCKLEBERRY_MENU_FOOTER_DEFAULT="  esc close"

# Display character for the space key in menus
HUCKLEBERRY_SPACE_DISPLAY="@huckleberry-space-display"
HUCKLEBERRY_SPACE_DISPLAY_DEFAULT="␣"

# Category: Sessions
HUCKLEBERRY_CAT_SESSIONS_KEY="@huckleberry-cat-sessions-key"
HUCKLEBERRY_CAT_SESSIONS_KEY_DEFAULT="space"

HUCKLEBERRY_CAT_SESSIONS_LABEL="@huckleberry-cat-sessions-label"
HUCKLEBERRY_CAT_SESSIONS_LABEL_DEFAULT="Find Session"

HUCKLEBERRY_CAT_SESSIONS_DESC="@huckleberry-cat-sessions-desc"
HUCKLEBERRY_CAT_SESSIONS_DESC_DEFAULT="Find, switch, create sessions"

# Category: Windows
HUCKLEBERRY_CAT_WINDOWS_KEY="@huckleberry-cat-windows-key"
HUCKLEBERRY_CAT_WINDOWS_KEY_DEFAULT="w"

HUCKLEBERRY_CAT_WINDOWS_LABEL="@huckleberry-cat-windows-label"
HUCKLEBERRY_CAT_WINDOWS_LABEL_DEFAULT="Windows"

HUCKLEBERRY_CAT_WINDOWS_DESC="@huckleberry-cat-windows-desc"
HUCKLEBERRY_CAT_WINDOWS_DESC_DEFAULT="Rename, new, kill, split, move windows"

# Category: Panes
HUCKLEBERRY_CAT_PANES_KEY="@huckleberry-cat-panes-key"
HUCKLEBERRY_CAT_PANES_KEY_DEFAULT="p"

HUCKLEBERRY_CAT_PANES_LABEL="@huckleberry-cat-panes-label"
HUCKLEBERRY_CAT_PANES_LABEL_DEFAULT="Panes"

HUCKLEBERRY_CAT_PANES_DESC="@huckleberry-cat-panes-desc"
HUCKLEBERRY_CAT_PANES_DESC_DEFAULT="Rename, new, layout, swap, move panes"

# Category: Session Management
HUCKLEBERRY_CAT_SESSION_MGMT_KEY="@huckleberry-cat-session-mgmt-key"
HUCKLEBERRY_CAT_SESSION_MGMT_KEY_DEFAULT="s"

HUCKLEBERRY_CAT_SESSION_MGMT_LABEL="@huckleberry-cat-session-mgmt-label"
HUCKLEBERRY_CAT_SESSION_MGMT_LABEL_DEFAULT="Sessions"

HUCKLEBERRY_CAT_SESSION_MGMT_DESC="@huckleberry-cat-session-mgmt-desc"
HUCKLEBERRY_CAT_SESSION_MGMT_DESC_DEFAULT="Rename, kill, create sessions"

# Category: Buffers
HUCKLEBERRY_CAT_BUFFERS_KEY="@huckleberry-cat-buffers-key"
HUCKLEBERRY_CAT_BUFFERS_KEY_DEFAULT="b"

HUCKLEBERRY_CAT_BUFFERS_LABEL="@huckleberry-cat-buffers-label"
HUCKLEBERRY_CAT_BUFFERS_LABEL_DEFAULT="Buffers"

HUCKLEBERRY_CAT_BUFFERS_DESC="@huckleberry-cat-buffers-desc"
HUCKLEBERRY_CAT_BUFFERS_DESC_DEFAULT="Paste, capture, manage buffers"

# Category: Toggles
HUCKLEBERRY_CAT_TOGGLES_KEY="@huckleberry-cat-toggles-key"
HUCKLEBERRY_CAT_TOGGLES_KEY_DEFAULT="t"

HUCKLEBERRY_CAT_TOGGLES_LABEL="@huckleberry-cat-toggles-label"
HUCKLEBERRY_CAT_TOGGLES_LABEL_DEFAULT="Toggles"

HUCKLEBERRY_CAT_TOGGLES_DESC="@huckleberry-cat-toggles-desc"
HUCKLEBERRY_CAT_TOGGLES_DESC_DEFAULT="Toggle tmux options on/off"

# Category: Config
HUCKLEBERRY_CAT_CONFIG_KEY="@huckleberry-cat-config-key"
HUCKLEBERRY_CAT_CONFIG_KEY_DEFAULT="c"

HUCKLEBERRY_CAT_CONFIG_LABEL="@huckleberry-cat-config-label"
HUCKLEBERRY_CAT_CONFIG_LABEL_DEFAULT="Config"

HUCKLEBERRY_CAT_CONFIG_DESC="@huckleberry-cat-config-desc"
HUCKLEBERRY_CAT_CONFIG_DESC_DEFAULT="Reload config, TPM install/update"

# ---------------------------------------------------------------------------
# Windows sub-palette
# ---------------------------------------------------------------------------

HUCKLEBERRY_WINDOWS_PROMPT="@huckleberry-windows-prompt"
HUCKLEBERRY_WINDOWS_PROMPT_DEFAULT="window > "

HUCKLEBERRY_WINDOWS_HEADER="@huckleberry-windows-header"
HUCKLEBERRY_WINDOWS_HEADER_DEFAULT="  Manage Windows"

HUCKLEBERRY_WINDOWS_FOOTER="@huckleberry-windows-footer"
HUCKLEBERRY_WINDOWS_FOOTER_DEFAULT="  esc back · 1-9 select · tab target"

HUCKLEBERRY_WIN_RENAME="@huckleberry-win-rename"
HUCKLEBERRY_WIN_RENAME_DEFAULT="Rename window"

HUCKLEBERRY_WIN_RENAME_PROMPT="@huckleberry-win-rename-prompt"
HUCKLEBERRY_WIN_RENAME_PROMPT_DEFAULT="name > "

HUCKLEBERRY_WIN_RENAME_HEADER="@huckleberry-win-rename-header"
HUCKLEBERRY_WIN_RENAME_HEADER_DEFAULT="  Rename Window"

HUCKLEBERRY_WIN_SPLIT_H="@huckleberry-win-split-h"
HUCKLEBERRY_WIN_SPLIT_H_DEFAULT="Split horizontal"

HUCKLEBERRY_WIN_SPLIT_V="@huckleberry-win-split-v"
HUCKLEBERRY_WIN_SPLIT_V_DEFAULT="Split vertical"

HUCKLEBERRY_WIN_MOVE_LEFT="@huckleberry-win-move-left"
HUCKLEBERRY_WIN_MOVE_LEFT_DEFAULT="Move window left"

HUCKLEBERRY_WIN_KILL="@huckleberry-win-kill"
HUCKLEBERRY_WIN_KILL_DEFAULT="Kill window"

HUCKLEBERRY_WIN_KILL_PICK_PROMPT="@huckleberry-win-kill-pick-prompt"
HUCKLEBERRY_WIN_KILL_PICK_PROMPT_DEFAULT="window > "

HUCKLEBERRY_WIN_KILL_PICK_HEADER="@huckleberry-win-kill-pick-header"
HUCKLEBERRY_WIN_KILL_PICK_HEADER_DEFAULT="  Kill Window"

HUCKLEBERRY_WIN_RENAME_PICK_PROMPT="@huckleberry-win-rename-pick-prompt"
HUCKLEBERRY_WIN_RENAME_PICK_PROMPT_DEFAULT="window > "

HUCKLEBERRY_WIN_RENAME_PICK_HEADER="@huckleberry-win-rename-pick-header"
HUCKLEBERRY_WIN_RENAME_PICK_HEADER_DEFAULT="  Rename Window"

HUCKLEBERRY_WIN_MOVE_RIGHT="@huckleberry-win-move-right"
HUCKLEBERRY_WIN_MOVE_RIGHT_DEFAULT="Move window right"

HUCKLEBERRY_WIN_NEW="@huckleberry-win-new"
HUCKLEBERRY_WIN_NEW_DEFAULT="New window"

HUCKLEBERRY_WIN_NEW_PROMPT="@huckleberry-win-new-prompt"
HUCKLEBERRY_WIN_NEW_PROMPT_DEFAULT="name > "

HUCKLEBERRY_WIN_NEW_HEADER="@huckleberry-win-new-header"
HUCKLEBERRY_WIN_NEW_HEADER_DEFAULT="  Create Window"

# ---------------------------------------------------------------------------
# Panes sub-palette
# ---------------------------------------------------------------------------

HUCKLEBERRY_PANES_PROMPT="@huckleberry-panes-prompt"
HUCKLEBERRY_PANES_PROMPT_DEFAULT="pane > "

HUCKLEBERRY_PANES_HEADER="@huckleberry-panes-header"
HUCKLEBERRY_PANES_HEADER_DEFAULT="  Manage Panes"

HUCKLEBERRY_PANES_FOOTER="@huckleberry-panes-footer"
HUCKLEBERRY_PANES_FOOTER_DEFAULT="  esc back · 1-9 select · tab target"

HUCKLEBERRY_PANE_RENAME="@huckleberry-pane-rename"
HUCKLEBERRY_PANE_RENAME_DEFAULT="Rename pane"

HUCKLEBERRY_PANE_RENAME_PROMPT="@huckleberry-pane-rename-prompt"
HUCKLEBERRY_PANE_RENAME_PROMPT_DEFAULT="title > "

HUCKLEBERRY_PANE_RENAME_HEADER="@huckleberry-pane-rename-header"
HUCKLEBERRY_PANE_RENAME_HEADER_DEFAULT="  Rename Pane"

HUCKLEBERRY_PANE_RENAME_PICK_PROMPT="@huckleberry-pane-rename-pick-prompt"
HUCKLEBERRY_PANE_RENAME_PICK_PROMPT_DEFAULT="pane > "

HUCKLEBERRY_PANE_RENAME_PICK_HEADER="@huckleberry-pane-rename-pick-header"
HUCKLEBERRY_PANE_RENAME_PICK_HEADER_DEFAULT="  Rename Pane"

HUCKLEBERRY_PANE_SELECT_LAYOUT="@huckleberry-pane-select-layout"
HUCKLEBERRY_PANE_SELECT_LAYOUT_DEFAULT="Select layout"

HUCKLEBERRY_PANE_LAYOUT_PROMPT="@huckleberry-pane-layout-prompt"
HUCKLEBERRY_PANE_LAYOUT_PROMPT_DEFAULT="layout > "

HUCKLEBERRY_PANE_LAYOUT_HEADER="@huckleberry-pane-layout-header"
HUCKLEBERRY_PANE_LAYOUT_HEADER_DEFAULT="  Select Layout"

HUCKLEBERRY_PANE_LAYOUT_EVEN_H="@huckleberry-pane-layout-even-h"
HUCKLEBERRY_PANE_LAYOUT_EVEN_H_DEFAULT="Even horizontal"

HUCKLEBERRY_PANE_LAYOUT_EVEN_V="@huckleberry-pane-layout-even-v"
HUCKLEBERRY_PANE_LAYOUT_EVEN_V_DEFAULT="Even vertical"

HUCKLEBERRY_PANE_LAYOUT_MAIN_H="@huckleberry-pane-layout-main-h"
HUCKLEBERRY_PANE_LAYOUT_MAIN_H_DEFAULT="Main horizontal"

HUCKLEBERRY_PANE_LAYOUT_MAIN_V="@huckleberry-pane-layout-main-v"
HUCKLEBERRY_PANE_LAYOUT_MAIN_V_DEFAULT="Main vertical"

HUCKLEBERRY_PANE_LAYOUT_TILED="@huckleberry-pane-layout-tiled"
HUCKLEBERRY_PANE_LAYOUT_TILED_DEFAULT="Tiled"

HUCKLEBERRY_PANE_SEND="@huckleberry-pane-send"
HUCKLEBERRY_PANE_SEND_DEFAULT="Send pane to window"

HUCKLEBERRY_PANE_SEND_PROMPT="@huckleberry-pane-send-prompt"
HUCKLEBERRY_PANE_SEND_PROMPT_DEFAULT="window > "

HUCKLEBERRY_PANE_SEND_HEADER="@huckleberry-pane-send-header"
HUCKLEBERRY_PANE_SEND_HEADER_DEFAULT="  Send Pane to Window"

HUCKLEBERRY_PANE_JOIN="@huckleberry-pane-join"
HUCKLEBERRY_PANE_JOIN_DEFAULT="Join pane from window"

HUCKLEBERRY_PANE_JOIN_PROMPT="@huckleberry-pane-join-prompt"
HUCKLEBERRY_PANE_JOIN_PROMPT_DEFAULT="pane > "

HUCKLEBERRY_PANE_JOIN_HEADER="@huckleberry-pane-join-header"
HUCKLEBERRY_PANE_JOIN_HEADER_DEFAULT="  Join Pane from Window"

HUCKLEBERRY_PANE_BREAK="@huckleberry-pane-break"
HUCKLEBERRY_PANE_BREAK_DEFAULT="Break pane to window"

HUCKLEBERRY_PANE_SWAP="@huckleberry-pane-swap"
HUCKLEBERRY_PANE_SWAP_DEFAULT="Swap pane"

HUCKLEBERRY_PANE_SWAP_PROMPT="@huckleberry-pane-swap-prompt"
HUCKLEBERRY_PANE_SWAP_PROMPT_DEFAULT="pane > "

HUCKLEBERRY_PANE_SWAP_HEADER="@huckleberry-pane-swap-header"
HUCKLEBERRY_PANE_SWAP_HEADER_DEFAULT="  Swap Pane"

HUCKLEBERRY_PANE_RESIZE="@huckleberry-pane-resize"
HUCKLEBERRY_PANE_RESIZE_DEFAULT="Resize pane"

HUCKLEBERRY_PANE_RESIZE_PROMPT="@huckleberry-pane-resize-prompt"
HUCKLEBERRY_PANE_RESIZE_PROMPT_DEFAULT="direction > "

HUCKLEBERRY_PANE_RESIZE_HEADER="@huckleberry-pane-resize-header"
HUCKLEBERRY_PANE_RESIZE_HEADER_DEFAULT="  Resize Pane"

HUCKLEBERRY_PANE_RESIZE_STEP="@huckleberry-pane-resize-step"
HUCKLEBERRY_PANE_RESIZE_STEP_DEFAULT="5"

HUCKLEBERRY_PANE_RESIZE_UP="@huckleberry-pane-resize-up"
HUCKLEBERRY_PANE_RESIZE_UP_DEFAULT="Grow up"

HUCKLEBERRY_PANE_RESIZE_DOWN="@huckleberry-pane-resize-down"
HUCKLEBERRY_PANE_RESIZE_DOWN_DEFAULT="Grow down"

HUCKLEBERRY_PANE_RESIZE_LEFT="@huckleberry-pane-resize-left"
HUCKLEBERRY_PANE_RESIZE_LEFT_DEFAULT="Grow left"

HUCKLEBERRY_PANE_RESIZE_RIGHT="@huckleberry-pane-resize-right"
HUCKLEBERRY_PANE_RESIZE_RIGHT_DEFAULT="Grow right"

HUCKLEBERRY_PANE_ZOOM="@huckleberry-pane-zoom"
HUCKLEBERRY_PANE_ZOOM_DEFAULT="Toggle zoom"

HUCKLEBERRY_PANE_ROTATE="@huckleberry-pane-rotate"
HUCKLEBERRY_PANE_ROTATE_DEFAULT="Rotate panes"

HUCKLEBERRY_PANE_DISPLAY_NUMBERS="@huckleberry-pane-display-numbers"
HUCKLEBERRY_PANE_DISPLAY_NUMBERS_DEFAULT="Display pane numbers"

HUCKLEBERRY_PANE_CLEAR_HISTORY="@huckleberry-pane-clear-history"
HUCKLEBERRY_PANE_CLEAR_HISTORY_DEFAULT="Clear scrollback"

HUCKLEBERRY_PANE_COPY_MODE="@huckleberry-pane-copy-mode"
HUCKLEBERRY_PANE_COPY_MODE_DEFAULT="Enter copy mode"

HUCKLEBERRY_PANE_RESPAWN="@huckleberry-pane-respawn"
HUCKLEBERRY_PANE_RESPAWN_DEFAULT="Respawn pane"

HUCKLEBERRY_PANE_NEW="@huckleberry-pane-new"
HUCKLEBERRY_PANE_NEW_DEFAULT="New pane"

HUCKLEBERRY_PANE_KILL="@huckleberry-pane-kill"
HUCKLEBERRY_PANE_KILL_DEFAULT="Kill pane"

HUCKLEBERRY_PANE_KILL_PICK_PROMPT="@huckleberry-pane-kill-pick-prompt"
HUCKLEBERRY_PANE_KILL_PICK_PROMPT_DEFAULT="pane > "

HUCKLEBERRY_PANE_KILL_PICK_HEADER="@huckleberry-pane-kill-pick-header"
HUCKLEBERRY_PANE_KILL_PICK_HEADER_DEFAULT="  Kill Pane"

# ---------------------------------------------------------------------------
# Session management sub-palette
# ---------------------------------------------------------------------------

HUCKLEBERRY_SESSION_MGMT_PROMPT="@huckleberry-session-mgmt-prompt"
HUCKLEBERRY_SESSION_MGMT_PROMPT_DEFAULT="session > "

HUCKLEBERRY_SESSION_MGMT_HEADER="@huckleberry-session-mgmt-header"
HUCKLEBERRY_SESSION_MGMT_HEADER_DEFAULT="  Manage Sessions"

HUCKLEBERRY_SESSION_MGMT_FOOTER="@huckleberry-session-mgmt-footer"
HUCKLEBERRY_SESSION_MGMT_FOOTER_DEFAULT="  esc back · 1-9 select · tab target"

HUCKLEBERRY_SES_RENAME="@huckleberry-ses-rename"
HUCKLEBERRY_SES_RENAME_DEFAULT="Rename session"

HUCKLEBERRY_SES_RENAME_PROMPT="@huckleberry-ses-rename-prompt"
HUCKLEBERRY_SES_RENAME_PROMPT_DEFAULT="name > "

HUCKLEBERRY_SES_RENAME_HEADER="@huckleberry-ses-rename-header"
HUCKLEBERRY_SES_RENAME_HEADER_DEFAULT="  Rename Session"

HUCKLEBERRY_SES_RENAME_PICK_PROMPT="@huckleberry-ses-rename-pick-prompt"
HUCKLEBERRY_SES_RENAME_PICK_PROMPT_DEFAULT="session > "

HUCKLEBERRY_SES_RENAME_PICK_HEADER="@huckleberry-ses-rename-pick-header"
HUCKLEBERRY_SES_RENAME_PICK_HEADER_DEFAULT="  Rename Session"

HUCKLEBERRY_SES_KILL="@huckleberry-ses-kill"
HUCKLEBERRY_SES_KILL_DEFAULT="Kill session"

HUCKLEBERRY_SES_KILL_PROMPT="@huckleberry-ses-kill-prompt"
HUCKLEBERRY_SES_KILL_PROMPT_DEFAULT="session > "

HUCKLEBERRY_SES_KILL_HEADER="@huckleberry-ses-kill-header"
HUCKLEBERRY_SES_KILL_HEADER_DEFAULT="  Kill Session"

HUCKLEBERRY_SES_NEW="@huckleberry-ses-new"
HUCKLEBERRY_SES_NEW_DEFAULT="New session"

HUCKLEBERRY_SES_NEW_PROMPT="@huckleberry-ses-new-prompt"
HUCKLEBERRY_SES_NEW_PROMPT_DEFAULT="name > "

HUCKLEBERRY_SES_NEW_HEADER="@huckleberry-ses-new-header"
HUCKLEBERRY_SES_NEW_HEADER_DEFAULT="  Create Session"

HUCKLEBERRY_SES_DETACH="@huckleberry-ses-detach"
HUCKLEBERRY_SES_DETACH_DEFAULT="Detach other clients"

# ---------------------------------------------------------------------------
# Buffers sub-palette
# ---------------------------------------------------------------------------

HUCKLEBERRY_BUFFERS_PROMPT="@huckleberry-buffers-prompt"
HUCKLEBERRY_BUFFERS_PROMPT_DEFAULT="buffer > "

HUCKLEBERRY_BUFFERS_HEADER="@huckleberry-buffers-header"
HUCKLEBERRY_BUFFERS_HEADER_DEFAULT="  Manage Buffers"

HUCKLEBERRY_BUFFERS_FOOTER="@huckleberry-buffers-footer"
HUCKLEBERRY_BUFFERS_FOOTER_DEFAULT="  esc back · 1-9 select"

HUCKLEBERRY_BUF_PASTE="@huckleberry-buf-paste"
HUCKLEBERRY_BUF_PASTE_DEFAULT="Paste buffer"

HUCKLEBERRY_BUF_CHOOSE="@huckleberry-buf-choose"
HUCKLEBERRY_BUF_CHOOSE_DEFAULT="Choose buffer"

HUCKLEBERRY_BUF_CHOOSE_PROMPT="@huckleberry-buf-choose-prompt"
HUCKLEBERRY_BUF_CHOOSE_PROMPT_DEFAULT="buffer > "

HUCKLEBERRY_BUF_CHOOSE_HEADER="@huckleberry-buf-choose-header"
HUCKLEBERRY_BUF_CHOOSE_HEADER_DEFAULT="  Choose Buffer"

HUCKLEBERRY_BUF_CHOOSE_PREVIEW="@huckleberry-buf-choose-preview"
HUCKLEBERRY_BUF_CHOOSE_PREVIEW_DEFAULT="right:50%"

HUCKLEBERRY_BUF_CAPTURE="@huckleberry-buf-capture"
HUCKLEBERRY_BUF_CAPTURE_DEFAULT="Capture pane to buffer"

HUCKLEBERRY_BUF_DELETE="@huckleberry-buf-delete"
HUCKLEBERRY_BUF_DELETE_DEFAULT="Delete buffer"

HUCKLEBERRY_BUF_DELETE_PROMPT="@huckleberry-buf-delete-prompt"
HUCKLEBERRY_BUF_DELETE_PROMPT_DEFAULT="buffer > "

HUCKLEBERRY_BUF_DELETE_HEADER="@huckleberry-buf-delete-header"
HUCKLEBERRY_BUF_DELETE_HEADER_DEFAULT="  Delete Buffer"

HUCKLEBERRY_BUF_SAVE="@huckleberry-buf-save"
HUCKLEBERRY_BUF_SAVE_DEFAULT="Save buffer to file"

HUCKLEBERRY_BUF_SAVE_PROMPT="@huckleberry-buf-save-prompt"
HUCKLEBERRY_BUF_SAVE_PROMPT_DEFAULT="path > "

HUCKLEBERRY_BUF_SAVE_HEADER="@huckleberry-buf-save-header"
HUCKLEBERRY_BUF_SAVE_HEADER_DEFAULT="  Save Buffer to File"

# ---------------------------------------------------------------------------
# Toggles sub-palette
# ---------------------------------------------------------------------------

HUCKLEBERRY_TOGGLES_PROMPT="@huckleberry-toggles-prompt"
HUCKLEBERRY_TOGGLES_PROMPT_DEFAULT="toggle > "

HUCKLEBERRY_TOGGLES_HEADER="@huckleberry-toggles-header"
HUCKLEBERRY_TOGGLES_HEADER_DEFAULT="  Toggle Options"

HUCKLEBERRY_TOGGLES_FOOTER="@huckleberry-toggles-footer"
HUCKLEBERRY_TOGGLES_FOOTER_DEFAULT="  esc back · 1-9 select"

HUCKLEBERRY_TOGGLE_ON_INDICATOR="@huckleberry-toggle-on-indicator"
HUCKLEBERRY_TOGGLE_ON_INDICATOR_DEFAULT="[on]"

HUCKLEBERRY_TOGGLE_OFF_INDICATOR="@huckleberry-toggle-off-indicator"
HUCKLEBERRY_TOGGLE_OFF_INDICATOR_DEFAULT="[off]"

HUCKLEBERRY_TOGGLE_SYNC_PANES="@huckleberry-toggle-sync-panes"
HUCKLEBERRY_TOGGLE_SYNC_PANES_DEFAULT="Synchronized panes"

HUCKLEBERRY_TOGGLE_MOUSE="@huckleberry-toggle-mouse"
HUCKLEBERRY_TOGGLE_MOUSE_DEFAULT="Mouse mode"

HUCKLEBERRY_TOGGLE_STATUS="@huckleberry-toggle-status"
HUCKLEBERRY_TOGGLE_STATUS_DEFAULT="Status bar"

HUCKLEBERRY_TOGGLE_PANE_BORDER="@huckleberry-toggle-pane-border"
HUCKLEBERRY_TOGGLE_PANE_BORDER_DEFAULT="Pane border status"

HUCKLEBERRY_TOGGLE_MONITOR_ACTIVITY="@huckleberry-toggle-monitor-activity"
HUCKLEBERRY_TOGGLE_MONITOR_ACTIVITY_DEFAULT="Monitor activity"

# ---------------------------------------------------------------------------
# Config sub-palette
# ---------------------------------------------------------------------------

HUCKLEBERRY_CONFIG_PROMPT="@huckleberry-config-prompt"
HUCKLEBERRY_CONFIG_PROMPT_DEFAULT="config > "

HUCKLEBERRY_CONFIG_HEADER="@huckleberry-config-header"
HUCKLEBERRY_CONFIG_HEADER_DEFAULT="  Configuration"

HUCKLEBERRY_CONFIG_FOOTER="@huckleberry-config-footer"
HUCKLEBERRY_CONFIG_FOOTER_DEFAULT="  esc back · 1-9 select"

HUCKLEBERRY_CFG_RELOAD="@huckleberry-cfg-reload"
HUCKLEBERRY_CFG_RELOAD_DEFAULT="Reload config"

HUCKLEBERRY_CFG_TPM_INSTALL="@huckleberry-cfg-tpm-install"
HUCKLEBERRY_CFG_TPM_INSTALL_DEFAULT="TPM install plugins"

HUCKLEBERRY_CFG_TPM_UPDATE="@huckleberry-cfg-tpm-update"
HUCKLEBERRY_CFG_TPM_UPDATE_DEFAULT="TPM update plugins"

# ---------------------------------------------------------------------------
# Category: Extensions (conditional — only shown when @huckleberry-extensions is set)
# ---------------------------------------------------------------------------

HUCKLEBERRY_CAT_EXTENSIONS_KEY="@huckleberry-cat-extensions-key"
HUCKLEBERRY_CAT_EXTENSIONS_KEY_DEFAULT="x"

HUCKLEBERRY_CAT_EXTENSIONS_LABEL="@huckleberry-cat-extensions-label"
HUCKLEBERRY_CAT_EXTENSIONS_LABEL_DEFAULT="Extensions"

HUCKLEBERRY_CAT_EXTENSIONS_DESC="@huckleberry-cat-extensions-desc"
HUCKLEBERRY_CAT_EXTENSIONS_DESC_DEFAULT="Run extension commands"

# ---------------------------------------------------------------------------
# Extensions sub-palette
# ---------------------------------------------------------------------------

# Comma-separated list of extension IDs (empty = palette hidden)
HUCKLEBERRY_EXTENSIONS="@huckleberry-extensions"

HUCKLEBERRY_EXTENSIONS_PROMPT="@huckleberry-extensions-prompt"
HUCKLEBERRY_EXTENSIONS_PROMPT_DEFAULT="extension > "

HUCKLEBERRY_EXTENSIONS_HEADER="@huckleberry-extensions-header"
HUCKLEBERRY_EXTENSIONS_HEADER_DEFAULT="  Extensions"

HUCKLEBERRY_EXTENSIONS_FOOTER="@huckleberry-extensions-footer"
HUCKLEBERRY_EXTENSIONS_FOOTER_DEFAULT="  esc back · 1-9 select"

HUCKLEBERRY_EXTENSIONS_ACTIONS_PROMPT="@huckleberry-extensions-actions-prompt"
HUCKLEBERRY_EXTENSIONS_ACTIONS_PROMPT_DEFAULT="action > "

HUCKLEBERRY_EXTENSIONS_ACTIONS_HEADER_PREFIX="@huckleberry-extensions-actions-header-prefix"
HUCKLEBERRY_EXTENSIONS_ACTIONS_HEADER_PREFIX_DEFAULT="  "

HUCKLEBERRY_EXTENSIONS_ACTIONS_FOOTER="@huckleberry-extensions-actions-footer"
HUCKLEBERRY_EXTENSIONS_ACTIONS_FOOTER_DEFAULT="  esc back · 1-9 select"
