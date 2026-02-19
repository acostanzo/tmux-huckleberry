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
