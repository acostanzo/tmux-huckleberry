#!/usr/bin/env bash
# shellcheck disable=SC1091  # sourced files are resolved at runtime
# Windows sub-palette — window management actions via fzf.
# Uses a while-true loop so Escape in sub-pickers returns to the action list.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=common.sh
source "${CURRENT_DIR}/common.sh"

strip_fzf_opts

get_tmux_option "$HUCKLEBERRY_WINDOWS_PROMPT" "$HUCKLEBERRY_WINDOWS_PROMPT_DEFAULT"; prompt="$REPLY"
get_tmux_option "$HUCKLEBERRY_WINDOWS_HEADER" "$HUCKLEBERRY_WINDOWS_HEADER_DEFAULT"; header="$REPLY"
get_tmux_option "$HUCKLEBERRY_WINDOWS_FOOTER" "$HUCKLEBERRY_WINDOWS_FOOTER_DEFAULT"; footer="$REPLY"
get_tmux_option "$HUCKLEBERRY_HEADER_BORDER" "$HUCKLEBERRY_HEADER_BORDER_DEFAULT"; header_border="$REPLY"
get_tmux_option "$HUCKLEBERRY_FOOTER_BORDER" "$HUCKLEBERRY_FOOTER_BORDER_DEFAULT"; footer_border="$REPLY"

header_border_args=(--header-border)
[[ -n "$header_border" ]] && header_border_args=(--header-border "$header_border")
footer_border_args=(--footer-border)
[[ -n "$footer_border" ]] && footer_border_args=(--footer-border "$footer_border")

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

# --- Main loop — sub-pickers return here on Escape ----------------------------

while true; do
    selection=$(echo "$actions" | fzf \
        --reverse \
        --no-info \
        --no-separator \
        --no-preview \
        --header-first \
        --delimiter '::' \
        --with-nth 2 \
        --prompt "$prompt" \
        --header "$header" \
        --footer "$footer" \
        "${header_border_args[@]}" \
        "${footer_border_args[@]}")

    fzf_exit=$?

    # Escape pressed — return to top-level menu (or exit if run directly).
    if [[ $fzf_exit -ne 0 ]]; then
        # shellcheck disable=SC2317
        return 0 2>/dev/null || exit 0
    fi

    # Extract the action ID (everything before the first "::").
    action="${selection%%::*}"

    case "$action" in
        rename)
            get_tmux_option "$HUCKLEBERRY_WIN_RENAME_PROMPT" "$HUCKLEBERRY_WIN_RENAME_PROMPT_DEFAULT"; rename_prompt="$REPLY"
            get_tmux_option "$HUCKLEBERRY_WIN_RENAME_HEADER" "$HUCKLEBERRY_WIN_RENAME_HEADER_DEFAULT"; rename_header="$REPLY"

            current_name=$(tmux display-message -p '#W')
            rename_output=$(printf '' | fzf \
                --print-query \
                --query "$current_name" \
                --prompt "$rename_prompt" \
                --header "$rename_header" \
                --reverse \
                --no-info \
                --no-separator \
                --no-preview \
                --header-first)

            rename_exit=$?

            if [[ $rename_exit -eq 130 ]]; then
                continue
            fi

            IFS= read -r new_name <<< "$rename_output"

            if [[ -n "$new_name" ]]; then
                tmux rename-window -- "$new_name"
                tmux set-window-option automatic-rename off
            fi
            exit 0
            ;;
        split-h)
            tmux split-window -h
            exit 0
            ;;
        split-v)
            tmux split-window -v
            exit 0
            ;;
        move-left)
            tmux swap-window -t -1 \; select-window -t -1
            exit 0
            ;;
        move-right)
            tmux swap-window -t +1 \; select-window -t +1
            exit 0
            ;;
    esac
done
