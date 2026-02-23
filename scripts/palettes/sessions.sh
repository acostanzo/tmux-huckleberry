#!/usr/bin/env bash
# shellcheck disable=SC1091  # sourced files are resolved at runtime
# Session palette — lists sessions through fzf; switch to selection or create a new one.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=common.sh
source "${CURRENT_DIR}/common.sh"

strip_fzf_opts

get_tmux_option "$HUCKLEBERRY_PROMPT" "$HUCKLEBERRY_PROMPT_DEFAULT"; prompt="$REPLY"
get_tmux_option "$HUCKLEBERRY_HEADER" "$HUCKLEBERRY_HEADER_DEFAULT"; header="$REPLY"
get_tmux_option "$HUCKLEBERRY_PREVIEW" "$HUCKLEBERRY_PREVIEW_DEFAULT"; preview="$REPLY"
get_tmux_option "$HUCKLEBERRY_MARKER" "$HUCKLEBERRY_MARKER_DEFAULT"; marker="$REPLY"
current_session="$(tmux display-message -p '#{session_name}')"

# Pad unmarked entries to align with the marker width.
printf -v padding '%*s' "${#marker}" ''

# Build the session list, marking the current session with a prefix.
session_list() {
    tmux list-sessions -F '#{session_name}' | while IFS= read -r name; do
        if [[ "$name" == "$current_session" ]]; then
            echo "${marker}${name}"
        else
            echo "${padding}${name}"
        fi
    done
}

# Run fzf and capture output.
# --print-query puts the raw query on line 1 and the selection on line 2.
# The preview string is intentionally single-quoted so fzf evaluates it per-line.
# shellcheck disable=SC2016
fzf_output=$(session_list | fzf \
    --print-query \
    --reverse \
    --no-info \
    --prompt "$prompt" \
    --header "$header" \
    --preview 'name={}; name="${name#"${name%%[a-zA-Z0-9]*}"}"; tmux list-windows -t "=$name" 2>/dev/null' \
    --preview-window "$preview")

fzf_exit=$?

# Parse output with bash read (no subprocess).
{
    IFS= read -r query
    IFS= read -r selection
} <<< "$fzf_output"

# Escape pressed — return to top-level menu (or exit if run directly).
if [[ $fzf_exit -eq 130 ]]; then
    # shellcheck disable=SC2317
    return 0 2>/dev/null || exit 0
fi

if [[ -n "$selection" ]]; then
    # Strip the marker or padding prefix to get the bare session name.
    target="${selection#"$marker"}"
    target="${target#"$padding"}"
    tmux switch-client -t "=$target"
    exit 0
elif [[ -n "$query" ]]; then
    # No match selected — create a new session with the query as its name.
    if ! valid_session_name "$query"; then
        tmux display-message "Invalid session name (cannot contain ':' or '.')"
        # shellcheck disable=SC2317
        return 0 2>/dev/null || exit 0
    fi
    if tmux has-session -t "=$query" 2>/dev/null; then
        tmux switch-client -t "=$query"
    else
        tmux new-session -d -s "$query"
        tmux set-window-option -t "=$query" automatic-rename off
        tmux rename-window -t "=$query" -- "$query"
        tmux switch-client -t "=$query"
    fi
    exit 0
fi
