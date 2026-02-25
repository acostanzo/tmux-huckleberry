#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2154  # sourced files; helper-set vars
# Find Window sub-palette — search all windows across all sessions via fzf.
# Uses a while-true loop so Escape returns to the top-level menu.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=common.sh
source "${CURRENT_DIR}/common.sh"

strip_fzf_opts

get_tmux_option "$HUCKLEBERRY_FIND_WINDOW_PROMPT" "$HUCKLEBERRY_FIND_WINDOW_PROMPT_DEFAULT"; prompt="$REPLY"
get_tmux_option "$HUCKLEBERRY_FIND_WINDOW_HEADER" "$HUCKLEBERRY_FIND_WINDOW_HEADER_DEFAULT"; header="$REPLY"
get_tmux_option "$HUCKLEBERRY_FIND_WINDOW_FOOTER" "$HUCKLEBERRY_FIND_WINDOW_FOOTER_DEFAULT"; footer="$REPLY"
get_tmux_option "$HUCKLEBERRY_FIND_WINDOW_FMT" "$HUCKLEBERRY_FIND_WINDOW_FMT_DEFAULT"; win_fmt="$REPLY"
get_tmux_option "$HUCKLEBERRY_FIND_WINDOW_PREVIEW" "$HUCKLEBERRY_FIND_WINDOW_PREVIEW_DEFAULT"; preview="$REPLY"
get_tmux_option "$HUCKLEBERRY_FIND_WINDOW_PREVIEW_FMT" "$HUCKLEBERRY_FIND_WINDOW_PREVIEW_FMT_DEFAULT"; preview_fmt="$REPLY"
get_tmux_option "$HUCKLEBERRY_HEADER_BORDER" "$HUCKLEBERRY_HEADER_BORDER_DEFAULT"; header_border="$REPLY"
get_tmux_option "$HUCKLEBERRY_FOOTER_BORDER" "$HUCKLEBERRY_FOOTER_BORDER_DEFAULT"; footer_border="$REPLY"

header_border_args=(--header-border)
[[ -n "$header_border" ]] && header_border_args=(--header-border "$header_border")
footer_border_args=(--footer-border)
[[ -n "$footer_border" ]] && footer_border_args=(--footer-border "$footer_border")

# Export preview format so fzf's preview subshell can see it.
export HUCK_FW_PREVIEW_FMT="$preview_fmt"

# --- Main loop — Escape returns to dispatcher --------------------------------

while true; do
    # Build window list: session:window_index as target ID, then formatted label.
    win_list=$(tmux list-windows -a -F "#{session_name}:#{window_index}::${win_fmt}")

    if [[ -z "$win_list" ]]; then
        tmux display-message "No windows found"
        # shellcheck disable=SC2317
        return 0 2>/dev/null || exit 0
    fi

    # Preview shows pane list for the highlighted window.
    # The {} placeholder contains the full line; we extract the target before ::.
    # shellcheck disable=SC2016
    selection=$(echo "$win_list" | SHELL="$BASH" fzf \
        --reverse \
        --no-info \
        --no-separator \
        --header-first \
        --delimiter '::' \
        --with-nth 2 \
        --prompt "$prompt" \
        --header "$header" \
        --footer "$footer" \
        "${header_border_args[@]}" \
        "${footer_border_args[@]}" \
        --preview 'target={}; target="${target%%::*}"; tmux list-panes -t "$target" -F "$HUCK_FW_PREVIEW_FMT" 2>/dev/null' \
        --preview-window "$preview")

    fzf_exit=$?

    # Escape pressed — return to top-level menu (or exit if run directly).
    if [[ $fzf_exit -ne 0 ]]; then
        # shellcheck disable=SC2317
        return 0 2>/dev/null || exit 0
    fi

    # Extract session:window_index target.
    target="${selection%%::*}"
    session="${target%%:*}"
    win_index="${target#*:}"

    tmux switch-client -t "=${session}:=${win_index}"
    exit 0
done
