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

# fzf prompt string
HUCKLEBERRY_PROMPT="@huckleberry-prompt"
HUCKLEBERRY_PROMPT_DEFAULT="session > "
