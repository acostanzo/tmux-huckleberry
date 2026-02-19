#!/usr/bin/env bash
# shellcheck disable=SC1091  # sourced files are resolved at runtime
# Windows sub-palette — window management actions via fzf.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=common.sh
source "${CURRENT_DIR}/common.sh"

strip_fzf_opts

get_tmux_option "$HUCKLEBERRY_WINDOWS_PROMPT" "$HUCKLEBERRY_WINDOWS_PROMPT_DEFAULT"; prompt="$REPLY"
get_tmux_option "$HUCKLEBERRY_WINDOWS_HEADER" "$HUCKLEBERRY_WINDOWS_HEADER_DEFAULT"; header="$REPLY"

get_tmux_option "$HUCKLEBERRY_WIN_RENAME" "$HUCKLEBERRY_WIN_RENAME_DEFAULT"; rename_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_WIN_SPLIT_H" "$HUCKLEBERRY_WIN_SPLIT_H_DEFAULT"; split_h_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_WIN_SPLIT_V" "$HUCKLEBERRY_WIN_SPLIT_V_DEFAULT"; split_v_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_WIN_MOVE_LEFT" "$HUCKLEBERRY_WIN_MOVE_LEFT_DEFAULT"; move_left_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_WIN_MOVE_RIGHT" "$HUCKLEBERRY_WIN_MOVE_RIGHT_DEFAULT"; move_right_label="$REPLY"

# action_id::label — fzf shows only the label, but returns the full string.
actions="rename::${rename_label}"
actions+=$'\n'"split-h::${split_h_label}"
actions+=$'\n'"split-v::${split_v_label}"
actions+=$'\n'"move-left::${move_left_label}"
actions+=$'\n'"move-right::${move_right_label}"

selection=$(echo "$actions" | fzf \
    --reverse \
    --no-info \
    --no-preview \
    --delimiter '::' \
    --with-nth 2 \
    --prompt "$prompt" \
    --header "$header")

fzf_exit=$?

# Escape pressed — return to top-level menu (or exit if run directly).
if [[ $fzf_exit -ne 0 ]]; then
    return 0 2>/dev/null || exit 0
fi

# Extract the action ID (everything before the first "::").
action="${selection%%::*}"

case "$action" in
    rename)
        tmux command-prompt -I "#W" "rename-window -- '%%'"
        ;;
    split-h)
        tmux split-window -h
        ;;
    split-v)
        tmux split-window -v
        ;;
    move-left)
        tmux swap-window -t -1 \; select-window -t -1
        ;;
    move-right)
        tmux swap-window -t +1 \; select-window -t +1
        ;;
esac
exit 0
