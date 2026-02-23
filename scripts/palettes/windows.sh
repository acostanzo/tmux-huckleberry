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
get_tmux_option "$HUCKLEBERRY_WIN_KILL" "$HUCKLEBERRY_WIN_KILL_DEFAULT"; kill_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_WIN_SPLIT_H" "$HUCKLEBERRY_WIN_SPLIT_H_DEFAULT"; split_h_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_WIN_SPLIT_V" "$HUCKLEBERRY_WIN_SPLIT_V_DEFAULT"; split_v_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_WIN_MOVE_LEFT" "$HUCKLEBERRY_WIN_MOVE_LEFT_DEFAULT"; move_left_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_WIN_MOVE_RIGHT" "$HUCKLEBERRY_WIN_MOVE_RIGHT_DEFAULT"; move_right_label="$REPLY"

# action_id::label — fzf shows only the label, but returns the full string.
actions="rename::${rename_label}"
actions+=$'\n'"kill::${kill_label}"
actions+=$'\n'"split-h::${split_h_label}"
actions+=$'\n'"split-v::${split_v_label}"
actions+=$'\n'"move-left::${move_left_label}"
actions+=$'\n'"move-right::${move_right_label}"

# --- Main loop — sub-pickers return here on Escape ----------------------------

while true; do
    fzf_output=$(echo "$actions" | fzf \
        --reverse \
        --no-info \
        --no-separator \
        --no-preview \
        --header-first \
        --expect=tab \
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

    # --expect outputs two lines: key pressed (empty for Enter), then the selection.
    IFS= read -r action_key <<< "${fzf_output%%$'\n'*}"
    IFS= read -r selection <<< "${fzf_output#*$'\n'}"

    # Extract the action ID (everything before the first "::").
    action="${selection%%::*}"

    case "$action" in
        rename)
            get_tmux_option "$HUCKLEBERRY_WIN_RENAME_PROMPT" "$HUCKLEBERRY_WIN_RENAME_PROMPT_DEFAULT"; rename_prompt="$REPLY"
            get_tmux_option "$HUCKLEBERRY_WIN_RENAME_HEADER" "$HUCKLEBERRY_WIN_RENAME_HEADER_DEFAULT"; rename_header="$REPLY"

            target_idx=""
            prefill=$(tmux display-message -p '#W')

            if [[ "$action_key" == "tab" ]]; then
                # Tab — pick a window to rename
                get_tmux_option "$HUCKLEBERRY_WIN_RENAME_PICK_PROMPT" "$HUCKLEBERRY_WIN_RENAME_PICK_PROMPT_DEFAULT"; pick_prompt="$REPLY"
                get_tmux_option "$HUCKLEBERRY_WIN_RENAME_PICK_HEADER" "$HUCKLEBERRY_WIN_RENAME_PICK_HEADER_DEFAULT"; pick_header="$REPLY"

                window_list=$(tmux list-windows -F '#{window_index}::#{window_index}: #{window_name}')

                if [[ -z "$window_list" ]]; then
                    continue
                fi

                if ! win_selection=$(echo "$window_list" | fzf \
                    --reverse \
                    --no-info \
                    --no-separator \
                    --no-preview \
                    --header-first \
                    --delimiter '::' \
                    --with-nth 2 \
                    --prompt "$pick_prompt" \
                    --header "$pick_header"); then
                    continue
                fi

                target_idx="${win_selection%%::*}"
                prefill=$(tmux display-message -t ":${target_idx}" -p '#W')
            fi

            rename_output=$(: | fzf \
                --print-query \
                --query "$prefill" \
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
                if [[ -n "$target_idx" ]]; then
                    tmux rename-window -t ":${target_idx}" -- "$new_name"
                    tmux set-window-option -t ":${target_idx}" automatic-rename off
                else
                    tmux rename-window -- "$new_name"
                    tmux set-window-option automatic-rename off
                fi
            fi
            exit 0
            ;;
        kill)
            if [[ "$action_key" == "tab" ]]; then
                # Tab — pick a window to kill
                get_tmux_option "$HUCKLEBERRY_WIN_KILL_PICK_PROMPT" "$HUCKLEBERRY_WIN_KILL_PICK_PROMPT_DEFAULT"; kill_prompt="$REPLY"
                get_tmux_option "$HUCKLEBERRY_WIN_KILL_PICK_HEADER" "$HUCKLEBERRY_WIN_KILL_PICK_HEADER_DEFAULT"; kill_header="$REPLY"

                window_list=$(tmux list-windows -F '#{window_index}::#{window_index}: #{window_name}')

                if [[ -z "$window_list" ]]; then
                    continue
                fi

                if ! win_selection=$(echo "$window_list" | fzf \
                    --reverse \
                    --no-info \
                    --no-separator \
                    --no-preview \
                    --header-first \
                    --delimiter '::' \
                    --with-nth 2 \
                    --prompt "$kill_prompt" \
                    --header "$kill_header"); then
                    continue
                fi

                target_idx="${win_selection%%::*}"
                tmux kill-window -t ":${target_idx}"
            else
                # Enter — kill current window
                tmux kill-window
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
