#!/usr/bin/env bash
# shellcheck disable=SC1091  # sourced files are resolved at runtime
# Panes sub-palette — pane management actions via fzf.
# Uses a while-true loop so Escape in sub-pickers returns to the action list.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=common.sh
source "${CURRENT_DIR}/common.sh"

strip_fzf_opts

get_tmux_option "$HUCKLEBERRY_PANES_PROMPT" "$HUCKLEBERRY_PANES_PROMPT_DEFAULT"; prompt="$REPLY"
get_tmux_option "$HUCKLEBERRY_PANES_HEADER" "$HUCKLEBERRY_PANES_HEADER_DEFAULT"; header="$REPLY"

get_tmux_option "$HUCKLEBERRY_PANE_SELECT_LAYOUT" "$HUCKLEBERRY_PANE_SELECT_LAYOUT_DEFAULT"; select_layout_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_PANE_SEND" "$HUCKLEBERRY_PANE_SEND_DEFAULT"; send_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_PANE_JOIN" "$HUCKLEBERRY_PANE_JOIN_DEFAULT"; join_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_PANE_BREAK" "$HUCKLEBERRY_PANE_BREAK_DEFAULT"; break_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_PANE_SWAP" "$HUCKLEBERRY_PANE_SWAP_DEFAULT"; swap_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_PANE_KILL" "$HUCKLEBERRY_PANE_KILL_DEFAULT"; kill_label="$REPLY"

# --- Build action list --------------------------------------------------------

actions="select-layout::${select_layout_label}"
actions+=$'\n'"send::${send_label}"
actions+=$'\n'"join::${join_label}"
actions+=$'\n'"break::${break_label}"
actions+=$'\n'"swap::${swap_label}"
actions+=$'\n'"kill::${kill_label}"

# --- Main loop — sub-pickers return here on Escape ----------------------------

while true; do
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
        select-layout)
            get_tmux_option "$HUCKLEBERRY_PANE_LAYOUT_PROMPT" "$HUCKLEBERRY_PANE_LAYOUT_PROMPT_DEFAULT"; layout_prompt="$REPLY"
            get_tmux_option "$HUCKLEBERRY_PANE_LAYOUT_HEADER" "$HUCKLEBERRY_PANE_LAYOUT_HEADER_DEFAULT"; layout_header="$REPLY"
            get_tmux_option "$HUCKLEBERRY_PANE_LAYOUT_EVEN_H" "$HUCKLEBERRY_PANE_LAYOUT_EVEN_H_DEFAULT"; even_h_label="$REPLY"
            get_tmux_option "$HUCKLEBERRY_PANE_LAYOUT_EVEN_V" "$HUCKLEBERRY_PANE_LAYOUT_EVEN_V_DEFAULT"; even_v_label="$REPLY"
            get_tmux_option "$HUCKLEBERRY_PANE_LAYOUT_MAIN_H" "$HUCKLEBERRY_PANE_LAYOUT_MAIN_H_DEFAULT"; main_h_label="$REPLY"
            get_tmux_option "$HUCKLEBERRY_PANE_LAYOUT_MAIN_V" "$HUCKLEBERRY_PANE_LAYOUT_MAIN_V_DEFAULT"; main_v_label="$REPLY"
            get_tmux_option "$HUCKLEBERRY_PANE_LAYOUT_TILED" "$HUCKLEBERRY_PANE_LAYOUT_TILED_DEFAULT"; tiled_label="$REPLY"

            layouts="even-horizontal::${even_h_label}"
            layouts+=$'\n'"even-vertical::${even_v_label}"
            layouts+=$'\n'"main-horizontal::${main_h_label}"
            layouts+=$'\n'"main-vertical::${main_v_label}"
            layouts+=$'\n'"tiled::${tiled_label}"

            layout_selection=$(echo "$layouts" | fzf \
                --reverse \
                --no-info \
                --no-preview \
                --delimiter '::' \
                --with-nth 2 \
                --prompt "$layout_prompt" \
                --header "$layout_header")

            layout_exit=$?

            # Escape in layout picker — back to action list.
            if [[ $layout_exit -ne 0 ]]; then
                continue
            fi

            layout="${layout_selection%%::*}"
            tmux select-layout "$layout"
            exit 0
            ;;
        send)
            get_tmux_option "$HUCKLEBERRY_PANE_SEND_PROMPT" "$HUCKLEBERRY_PANE_SEND_PROMPT_DEFAULT"; send_prompt="$REPLY"
            get_tmux_option "$HUCKLEBERRY_PANE_SEND_HEADER" "$HUCKLEBERRY_PANE_SEND_HEADER_DEFAULT"; send_header="$REPLY"

            current_window=$(tmux display-message -p '#{window_index}')
            window_list=$(tmux list-windows -F '#{window_index}: #{window_name}' \
                | while IFS= read -r line; do
                    idx="${line%%:*}"
                    if [[ "$idx" != "$current_window" ]]; then
                        echo "$line"
                    fi
                done)

            if [[ -z "$window_list" ]]; then
                tmux display-message "No other windows"
                continue
            fi

            win_selection=$(echo "$window_list" | fzf \
                --reverse \
                --no-info \
                --no-preview \
                --prompt "$send_prompt" \
                --header "$send_header")

            win_exit=$?

            if [[ $win_exit -ne 0 ]]; then
                continue
            fi

            window_index="${win_selection%%:*}"
            tmux join-pane -t ":${window_index}"
            exit 0
            ;;
        join)
            get_tmux_option "$HUCKLEBERRY_PANE_JOIN_PROMPT" "$HUCKLEBERRY_PANE_JOIN_PROMPT_DEFAULT"; join_prompt="$REPLY"
            get_tmux_option "$HUCKLEBERRY_PANE_JOIN_HEADER" "$HUCKLEBERRY_PANE_JOIN_HEADER_DEFAULT"; join_header="$REPLY"

            current_window=$(tmux display-message -p '#{window_index}')
            pane_list=$(tmux list-panes -s \
                -F '#{window_index}.#{pane_index}::#{window_index}:#{window_name}.#{pane_index} - #{pane_current_command}' \
                | while IFS= read -r line; do
                    target="${line%%::*}"
                    win="${target%%.*}"
                    if [[ "$win" != "$current_window" ]]; then
                        echo "$line"
                    fi
                done)

            if [[ -z "$pane_list" ]]; then
                tmux display-message "No panes in other windows"
                continue
            fi

            pane_selection=$(echo "$pane_list" | fzf \
                --reverse \
                --no-info \
                --no-preview \
                --delimiter '::' \
                --with-nth 2 \
                --prompt "$join_prompt" \
                --header "$join_header")

            pane_exit=$?

            if [[ $pane_exit -ne 0 ]]; then
                continue
            fi

            target="${pane_selection%%::*}"
            tmux join-pane -s ":${target}"
            exit 0
            ;;
        break)
            tmux break-pane
            exit 0
            ;;
        swap)
            get_tmux_option "$HUCKLEBERRY_PANE_SWAP_PROMPT" "$HUCKLEBERRY_PANE_SWAP_PROMPT_DEFAULT"; swap_prompt="$REPLY"
            get_tmux_option "$HUCKLEBERRY_PANE_SWAP_HEADER" "$HUCKLEBERRY_PANE_SWAP_HEADER_DEFAULT"; swap_header="$REPLY"

            current_pane=$(tmux display-message -p '#{pane_index}')
            swap_list=$(tmux list-panes \
                -F '#{pane_index}::#{pane_index}: #{pane_current_command} (#{pane_width}x#{pane_height})' \
                | while IFS= read -r line; do
                    idx="${line%%::*}"
                    if [[ "$idx" != "$current_pane" ]]; then
                        echo "$line"
                    fi
                done)

            if [[ -z "$swap_list" ]]; then
                tmux display-message "No other panes"
                continue
            fi

            swap_selection=$(echo "$swap_list" | fzf \
                --reverse \
                --no-info \
                --no-preview \
                --delimiter '::' \
                --with-nth 2 \
                --prompt "$swap_prompt" \
                --header "$swap_header")

            swap_exit=$?

            if [[ $swap_exit -ne 0 ]]; then
                continue
            fi

            pane_index="${swap_selection%%::*}"
            tmux swap-pane -t "$pane_index"
            exit 0
            ;;
        kill)
            tmux kill-pane
            exit 0
            ;;
    esac
done
