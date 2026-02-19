#!/usr/bin/env bash
# shellcheck disable=SC1091  # sourced files are resolved at runtime
# Session palette — lists sessions through fzf; switch to selection or create a new one.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=common.sh
source "${CURRENT_DIR}/common.sh"

strip_fzf_opts

prompt=$(get_tmux_option "$HUCKLEBERRY_PROMPT" "$HUCKLEBERRY_PROMPT_DEFAULT")
header=$(get_tmux_option "$HUCKLEBERRY_HEADER" "$HUCKLEBERRY_HEADER_DEFAULT")
preview=$(get_tmux_option "$HUCKLEBERRY_PREVIEW" "$HUCKLEBERRY_PREVIEW_DEFAULT")
marker=$(get_tmux_option "$HUCKLEBERRY_MARKER" "$HUCKLEBERRY_MARKER_DEFAULT")
current_session="$(tmux display-message -p '#{session_name}')"

# Pad unmarked entries to align with the marker width.
padding=$(printf '%*s' "${#marker}" '')

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
    --preview 'tmux list-windows -t $(echo {} | sed "s/^[^a-zA-Z0-9]*//") 2>/dev/null' \
    --preview-window "$preview")

fzf_exit=$?

query=$(echo "$fzf_output" | head -n 1)
selection=$(echo "$fzf_output" | sed -n '2p')

# Escape pressed — exit cleanly.
if [[ $fzf_exit -eq 130 ]]; then
    exit 0
fi

if [[ -n "$selection" ]]; then
    # Strip the marker or padding prefix to get the bare session name.
    target="${selection#"$marker"}"
    target="${target#"$padding"}"
    tmux switch-client -t "=$target"
elif [[ -n "$query" ]]; then
    # No match selected — create a new session with the query as its name.
    if tmux has-session -t "=$query" 2>/dev/null; then
        tmux switch-client -t "=$query"
    else
        tmux new-session -d -s "$query"
        tmux set-window-option -t "=$query" automatic-rename off
        tmux rename-window -t "=$query" "$query"
        tmux switch-client -t "=$query"
    fi
fi
