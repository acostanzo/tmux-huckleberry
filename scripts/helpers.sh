#!/usr/bin/env bash
# Utility functions sourced by other scripts.

# Guard for common.sh to skip redundant re-sourcing.
_huck_helpers_loaded=1

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

# Validate a tmux session name. Returns 0 if valid, 1 if not.
# tmux forbids ':' and '.' in session names (they delimit targets).
valid_session_name() {
    local name="$1"
    [[ -n "$name" && "$name" != *[.:]*  ]]
}

# Strip layout options from FZF_DEFAULT_OPTS that conflict with the popup:
#   --height: forces inline mode, leaving a gap at the bottom
#   --border: redundant with the tmux popup border
strip_fzf_opts() {
    shopt -s extglob
    FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS//--height=*([^ ])/}"
    FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS//--border*([^ ])/}"
    export FZF_DEFAULT_OPTS
}

# Prepend 1-based number prefixes to action labels for hotkey display.
#   $1 — newline-delimited action_id::label string
# Sets:
#   REPLY              — numbered actions string (pipe to fzf)
#   _huck_action_ids   — indexed array of action IDs
#   _huck_expect_keys  — comma-separated number keys for --expect
_huck_number_actions() {
    _huck_action_ids=()
    local numbered="" n=0
    while IFS= read -r _line; do
        (( n++ ))
        _huck_action_ids+=("${_line%%::*}")
        [[ -n "$numbered" ]] && numbered+=$'\n'
        numbered+="${_line%%::*}::${n}  ${_line#*::}"
    done <<< "$1"
    REPLY="$numbered"
    _huck_expect_keys=""
    local i
    for (( i=1; i<=n; i++ )); do
        [[ -n "$_huck_expect_keys" ]] && _huck_expect_keys+=","
        _huck_expect_keys+="${i}"
    done
}

# Resolve a number hotkey to an action ID, or fall through to selection.
#   $1 — action_key from fzf --expect output
#   $2 — selection line from fzf output
# Sets:
#   REPLY              — resolved action ID
#   _huck_resolved_key — effective key ("" for number hotkeys, original key otherwise)
_huck_resolve_hotkey() {
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        REPLY="${_huck_action_ids[$(($1 - 1))]}"
        _huck_resolved_key=""
    else
        REPLY="${2%%::*}"
        _huck_resolved_key="$1"
    fi
}
