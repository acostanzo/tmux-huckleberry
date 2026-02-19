#!/usr/bin/env bash
# Utility functions sourced by other scripts.

# Read a tmux user option, returning a default when unset.
#   $1 — option name (e.g. @huckleberry-bind)
#   $2 — default value
get_tmux_option() {
    local option="$1"
    local default_value="$2"
    local value
    value="$(tmux show-option -gqv "$option")"
    echo "${value:-$default_value}"
}
