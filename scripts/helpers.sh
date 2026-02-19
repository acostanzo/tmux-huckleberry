#!/usr/bin/env bash
# Utility functions sourced by other scripts.

# Lazy-loaded cache of @huckleberry- options — a single tmux round-trip
# replaces the per-option calls that were the main source of startup lag.
# Conditional init prevents re-sourcing from clobbering a populated cache.
: "${_huck_options_loaded:=0}"

_load_options_cache() {
    _huck_options_cache=$(tmux show-options -g 2>/dev/null | grep '^@huckleberry-')
    _huck_options_loaded=1
}

# Read a tmux user option into REPLY, falling back to a default.
#   $1 — option name (e.g. @huckleberry-bind)
#   $2 — default value
# Result is in $REPLY (avoids subshell fork from command substitution).
get_tmux_option() {
    local option="$1"
    local default_value="$2"

    if [[ "$_huck_options_loaded" -eq 0 ]]; then
        _load_options_cache
    fi

    local line
    while IFS= read -r line; do
        if [[ "$line" == "${option} "* ]]; then
            REPLY="${line#"${option} "}"
            # tmux wraps string values in quotes — strip them.
            REPLY="${REPLY#\"}"
            REPLY="${REPLY%\"}"
            return
        fi
    done <<< "$_huck_options_cache"

    REPLY="$default_value"
}
