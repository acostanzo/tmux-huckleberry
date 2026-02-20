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
HUCKLEBERRY_TITLE_DEFAULT=" 🤠 huckleberry "

# Popup border line style (single, rounded, double, heavy, simple, padded, none)
HUCKLEBERRY_BORDER_LINES="@huckleberry-border-lines"
HUCKLEBERRY_BORDER_LINES_DEFAULT="rounded"

# fzf prompt string
HUCKLEBERRY_PROMPT="@huckleberry-prompt"
HUCKLEBERRY_PROMPT_DEFAULT="session > "

# fzf header text
HUCKLEBERRY_HEADER="@huckleberry-header"
HUCKLEBERRY_HEADER_DEFAULT="  switch or create a session"

# fzf preview window layout
HUCKLEBERRY_PREVIEW="@huckleberry-preview"
HUCKLEBERRY_PREVIEW_DEFAULT="right:50%"

# Current session marker prefix
HUCKLEBERRY_MARKER="@huckleberry-marker"
HUCKLEBERRY_MARKER_DEFAULT="* "

# ---------------------------------------------------------------------------
# Top-level menu
# ---------------------------------------------------------------------------

HUCKLEBERRY_MENU_PROMPT="@huckleberry-menu-prompt"
HUCKLEBERRY_MENU_PROMPT_DEFAULT="  "

HUCKLEBERRY_MENU_HEADER="@huckleberry-menu-header"
HUCKLEBERRY_MENU_HEADER_DEFAULT="command palette"

# Display character for the space key in menus
HUCKLEBERRY_SPACE_DISPLAY="@huckleberry-space-display"
HUCKLEBERRY_SPACE_DISPLAY_DEFAULT="␣"

# Category: Sessions
HUCKLEBERRY_CAT_SESSIONS_KEY="@huckleberry-cat-sessions-key"
HUCKLEBERRY_CAT_SESSIONS_KEY_DEFAULT="space"

HUCKLEBERRY_CAT_SESSIONS_LABEL="@huckleberry-cat-sessions-label"
HUCKLEBERRY_CAT_SESSIONS_LABEL_DEFAULT="Sessions"

HUCKLEBERRY_CAT_SESSIONS_DESC="@huckleberry-cat-sessions-desc"
HUCKLEBERRY_CAT_SESSIONS_DESC_DEFAULT="Switch or create sessions"

# Category: Windows
HUCKLEBERRY_CAT_WINDOWS_KEY="@huckleberry-cat-windows-key"
HUCKLEBERRY_CAT_WINDOWS_KEY_DEFAULT="w"

HUCKLEBERRY_CAT_WINDOWS_LABEL="@huckleberry-cat-windows-label"
HUCKLEBERRY_CAT_WINDOWS_LABEL_DEFAULT="Windows"

HUCKLEBERRY_CAT_WINDOWS_DESC="@huckleberry-cat-windows-desc"
HUCKLEBERRY_CAT_WINDOWS_DESC_DEFAULT="Rename, split, move windows"

# Category: Panes
HUCKLEBERRY_CAT_PANES_KEY="@huckleberry-cat-panes-key"
HUCKLEBERRY_CAT_PANES_KEY_DEFAULT="p"

HUCKLEBERRY_CAT_PANES_LABEL="@huckleberry-cat-panes-label"
HUCKLEBERRY_CAT_PANES_LABEL_DEFAULT="Panes"

HUCKLEBERRY_CAT_PANES_DESC="@huckleberry-cat-panes-desc"
HUCKLEBERRY_CAT_PANES_DESC_DEFAULT="Layout, swap, move panes"

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
HUCKLEBERRY_WINDOWS_HEADER_DEFAULT="  pick a window action"

HUCKLEBERRY_WIN_RENAME="@huckleberry-win-rename"
HUCKLEBERRY_WIN_RENAME_DEFAULT="Rename window"

HUCKLEBERRY_WIN_SPLIT_H="@huckleberry-win-split-h"
HUCKLEBERRY_WIN_SPLIT_H_DEFAULT="Split horizontal"

HUCKLEBERRY_WIN_SPLIT_V="@huckleberry-win-split-v"
HUCKLEBERRY_WIN_SPLIT_V_DEFAULT="Split vertical"

HUCKLEBERRY_WIN_MOVE_LEFT="@huckleberry-win-move-left"
HUCKLEBERRY_WIN_MOVE_LEFT_DEFAULT="Move window left"

HUCKLEBERRY_WIN_MOVE_RIGHT="@huckleberry-win-move-right"
HUCKLEBERRY_WIN_MOVE_RIGHT_DEFAULT="Move window right"

# ---------------------------------------------------------------------------
# Panes sub-palette
# ---------------------------------------------------------------------------

HUCKLEBERRY_PANES_PROMPT="@huckleberry-panes-prompt"
HUCKLEBERRY_PANES_PROMPT_DEFAULT="pane > "

HUCKLEBERRY_PANES_HEADER="@huckleberry-panes-header"
HUCKLEBERRY_PANES_HEADER_DEFAULT="  pick a pane action"

HUCKLEBERRY_PANE_SELECT_LAYOUT="@huckleberry-pane-select-layout"
HUCKLEBERRY_PANE_SELECT_LAYOUT_DEFAULT="Select layout"

HUCKLEBERRY_PANE_LAYOUT_PROMPT="@huckleberry-pane-layout-prompt"
HUCKLEBERRY_PANE_LAYOUT_PROMPT_DEFAULT="layout > "

HUCKLEBERRY_PANE_LAYOUT_HEADER="@huckleberry-pane-layout-header"
HUCKLEBERRY_PANE_LAYOUT_HEADER_DEFAULT="  pick a layout"

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
HUCKLEBERRY_PANE_SEND_HEADER_DEFAULT="  send pane to window"

HUCKLEBERRY_PANE_JOIN="@huckleberry-pane-join"
HUCKLEBERRY_PANE_JOIN_DEFAULT="Join pane from window"

HUCKLEBERRY_PANE_JOIN_PROMPT="@huckleberry-pane-join-prompt"
HUCKLEBERRY_PANE_JOIN_PROMPT_DEFAULT="pane > "

HUCKLEBERRY_PANE_JOIN_HEADER="@huckleberry-pane-join-header"
HUCKLEBERRY_PANE_JOIN_HEADER_DEFAULT="  join pane from another window"

HUCKLEBERRY_PANE_BREAK="@huckleberry-pane-break"
HUCKLEBERRY_PANE_BREAK_DEFAULT="Break pane to window"

HUCKLEBERRY_PANE_SWAP="@huckleberry-pane-swap"
HUCKLEBERRY_PANE_SWAP_DEFAULT="Swap pane"

HUCKLEBERRY_PANE_SWAP_PROMPT="@huckleberry-pane-swap-prompt"
HUCKLEBERRY_PANE_SWAP_PROMPT_DEFAULT="pane > "

HUCKLEBERRY_PANE_SWAP_HEADER="@huckleberry-pane-swap-header"
HUCKLEBERRY_PANE_SWAP_HEADER_DEFAULT="  swap with pane"

HUCKLEBERRY_PANE_KILL="@huckleberry-pane-kill"
HUCKLEBERRY_PANE_KILL_DEFAULT="Kill pane"

# ---------------------------------------------------------------------------
# Config sub-palette
# ---------------------------------------------------------------------------

HUCKLEBERRY_CONFIG_PROMPT="@huckleberry-config-prompt"
HUCKLEBERRY_CONFIG_PROMPT_DEFAULT="config > "

HUCKLEBERRY_CONFIG_HEADER="@huckleberry-config-header"
HUCKLEBERRY_CONFIG_HEADER_DEFAULT="  pick a config action"

HUCKLEBERRY_CFG_RELOAD="@huckleberry-cfg-reload"
HUCKLEBERRY_CFG_RELOAD_DEFAULT="Reload config"

HUCKLEBERRY_CFG_TPM_INSTALL="@huckleberry-cfg-tpm-install"
HUCKLEBERRY_CFG_TPM_INSTALL_DEFAULT="TPM install plugins"

HUCKLEBERRY_CFG_TPM_UPDATE="@huckleberry-cfg-tpm-update"
HUCKLEBERRY_CFG_TPM_UPDATE_DEFAULT="TPM update plugins"
