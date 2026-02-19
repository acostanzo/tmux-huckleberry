#!/usr/bin/env bash
# shellcheck disable=SC1091  # sourced files are resolved at runtime
# Windows sub-palette — window management actions via fzf.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=common.sh
source "${CURRENT_DIR}/common.sh"

strip_fzf_opts

prompt=$(get_tmux_option "$HUCKLEBERRY_WINDOWS_PROMPT" "$HUCKLEBERRY_WINDOWS_PROMPT_DEFAULT")
header=$(get_tmux_option "$HUCKLEBERRY_WINDOWS_HEADER" "$HUCKLEBERRY_WINDOWS_HEADER_DEFAULT")

rename_label=$(get_tmux_option "$HUCKLEBERRY_WIN_RENAME" "$HUCKLEBERRY_WIN_RENAME_DEFAULT")
split_h_label=$(get_tmux_option "$HUCKLEBERRY_WIN_SPLIT_H" "$HUCKLEBERRY_WIN_SPLIT_H_DEFAULT")
split_v_label=$(get_tmux_option "$HUCKLEBERRY_WIN_SPLIT_V" "$HUCKLEBERRY_WIN_SPLIT_V_DEFAULT")
move_left_label=$(get_tmux_option "$HUCKLEBERRY_WIN_MOVE_LEFT" "$HUCKLEBERRY_WIN_MOVE_LEFT_DEFAULT")
move_right_label=$(get_tmux_option "$HUCKLEBERRY_WIN_MOVE_RIGHT" "$HUCKLEBERRY_WIN_MOVE_RIGHT_DEFAULT")

# action_id::label — fzf shows only the label, but returns the full string.
actions=$(printf '%s\n' \
    "rename::${rename_label}" \
    "split-h::${split_h_label}" \
    "split-v::${split_v_label}" \
    "move-left::${move_left_label}" \
    "move-right::${move_right_label}")

selection=$(echo "$actions" | fzf \
    --reverse \
    --no-info \
    --no-preview \
    --delimiter '::' \
    --with-nth 2 \
    --prompt "$prompt" \
    --header "$header")

fzf_exit=$?

if [[ $fzf_exit -ne 0 ]]; then
    exit 0
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
