#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2154  # sourced files; helper-set vars
# Panes sub-palette — pane management actions via fzf.
# Uses a while-true loop so Escape in sub-pickers returns to the action list.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=common.sh
source "${CURRENT_DIR}/common.sh"

strip_fzf_opts

get_tmux_option "$HUCKLEBERRY_PANES_PROMPT" "$HUCKLEBERRY_PANES_PROMPT_DEFAULT"; prompt="$REPLY"
get_tmux_option "$HUCKLEBERRY_PANES_HEADER" "$HUCKLEBERRY_PANES_HEADER_DEFAULT"; header="$REPLY"
get_tmux_option "$HUCKLEBERRY_PANES_FOOTER" "$HUCKLEBERRY_PANES_FOOTER_DEFAULT"; footer="$REPLY"
get_tmux_option "$HUCKLEBERRY_HEADER_BORDER" "$HUCKLEBERRY_HEADER_BORDER_DEFAULT"; header_border="$REPLY"
get_tmux_option "$HUCKLEBERRY_FOOTER_BORDER" "$HUCKLEBERRY_FOOTER_BORDER_DEFAULT"; footer_border="$REPLY"

header_border_args=(--header-border)
[[ -n "$header_border" ]] && header_border_args=(--header-border "$header_border")
footer_border_args=(--footer-border)
[[ -n "$footer_border" ]] && footer_border_args=(--footer-border "$footer_border")

get_tmux_option "$HUCKLEBERRY_PANE_RENAME" "$HUCKLEBERRY_PANE_RENAME_DEFAULT"; rename_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_PANE_SELECT_LAYOUT" "$HUCKLEBERRY_PANE_SELECT_LAYOUT_DEFAULT"; select_layout_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_PANE_SEND" "$HUCKLEBERRY_PANE_SEND_DEFAULT"; send_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_PANE_JOIN" "$HUCKLEBERRY_PANE_JOIN_DEFAULT"; join_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_PANE_BREAK" "$HUCKLEBERRY_PANE_BREAK_DEFAULT"; break_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_PANE_SWAP" "$HUCKLEBERRY_PANE_SWAP_DEFAULT"; swap_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_PANE_ZOOM" "$HUCKLEBERRY_PANE_ZOOM_DEFAULT"; zoom_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_PANE_ROTATE" "$HUCKLEBERRY_PANE_ROTATE_DEFAULT"; rotate_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_PANE_DISPLAY_NUMBERS" "$HUCKLEBERRY_PANE_DISPLAY_NUMBERS_DEFAULT"; display_numbers_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_PANE_CLEAR_HISTORY" "$HUCKLEBERRY_PANE_CLEAR_HISTORY_DEFAULT"; clear_history_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_PANE_COPY_MODE" "$HUCKLEBERRY_PANE_COPY_MODE_DEFAULT"; copy_mode_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_PANE_RESPAWN" "$HUCKLEBERRY_PANE_RESPAWN_DEFAULT"; respawn_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_PANE_NEW" "$HUCKLEBERRY_PANE_NEW_DEFAULT"; new_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_PANE_KILL" "$HUCKLEBERRY_PANE_KILL_DEFAULT"; kill_label="$REPLY"

# --- Build action list --------------------------------------------------------

actions="new::${new_label}"
actions+=$'\n'"zoom::${zoom_label}"
actions+=$'\n'"select-layout::${select_layout_label}"
actions+=$'\n'"swap::${swap_label}"
actions+=$'\n'"rotate::${rotate_label}"
actions+=$'\n'"send::${send_label}"
actions+=$'\n'"join::${join_label}"
actions+=$'\n'"break::${break_label}"
actions+=$'\n'"copy-mode::${copy_mode_label}"
actions+=$'\n'"clear-history::${clear_history_label}"
actions+=$'\n'"display-numbers::${display_numbers_label}"
actions+=$'\n'"respawn::${respawn_label}"
actions+=$'\n'"rename::${rename_label}"
actions+=$'\n'"kill::${kill_label}"

# --- Number actions for hotkey display -----------------------------------------

_huck_number_actions "$actions"
actions="$REPLY"

# --- Main loop — sub-pickers return here on Escape ----------------------------

while true; do
    fzf_output=$(echo "$actions" | fzf \
        --reverse \
        --no-info \
        --no-separator \
        --no-preview \
        --header-first \
        --expect="tab,${_huck_expect_keys}" \
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

    # Resolve number hotkeys to action IDs; pass through Enter/Tab.
    _huck_resolve_hotkey "$action_key" "$selection"
    action="$REPLY"
    action_key="$_huck_resolved_key"

    case "$action" in
        rename)
            get_tmux_option "$HUCKLEBERRY_PANE_RENAME_PROMPT" "$HUCKLEBERRY_PANE_RENAME_PROMPT_DEFAULT"; rename_prompt="$REPLY"
            get_tmux_option "$HUCKLEBERRY_PANE_RENAME_HEADER" "$HUCKLEBERRY_PANE_RENAME_HEADER_DEFAULT"; rename_header="$REPLY"

            target_idx=""
            prefill=$(tmux display-message -p '#{pane_title}')

            if [[ "$action_key" == "tab" ]]; then
                # Tab — pick a pane to rename
                get_tmux_option "$HUCKLEBERRY_PANE_RENAME_PICK_PROMPT" "$HUCKLEBERRY_PANE_RENAME_PICK_PROMPT_DEFAULT"; pick_prompt="$REPLY"
                get_tmux_option "$HUCKLEBERRY_PANE_RENAME_PICK_HEADER" "$HUCKLEBERRY_PANE_RENAME_PICK_HEADER_DEFAULT"; pick_header="$REPLY"

                pane_list=$(tmux list-panes \
                    -F '#{pane_index}::#{pane_index}: #{pane_current_command} (#{pane_width}x#{pane_height})')

                if [[ -z "$pane_list" ]]; then
                    continue
                fi

                if ! pane_selection=$(echo "$pane_list" | fzf \
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

                target_idx="${pane_selection%%::*}"
                prefill=$(tmux display-message -t "$target_idx" -p '#{pane_title}')
            fi

            rename_output=$(: | fzf \
                --print-query \
                --reverse \
                --no-info \
                --no-separator \
                --no-preview \
                --header-first \
                --query "$prefill" \
                --prompt "$rename_prompt" \
                --header "$rename_header")

            rename_exit=$?

            if [[ $rename_exit -eq 130 ]]; then
                continue
            fi

            IFS= read -r new_title <<< "$rename_output"

            if [[ -n "$new_title" ]]; then
                if [[ -n "$target_idx" ]]; then
                    tmux select-pane -t "$target_idx" -T "$new_title"
                else
                    tmux select-pane -T "$new_title"
                fi
            fi
            exit 0
            ;;
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
                --no-separator \
                --no-preview \
                --header-first \
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
        new)
            tmux split-window
            exit 0
            ;;
        zoom)
            tmux resize-pane -Z
            exit 0
            ;;
        rotate)
            tmux rotate-window
            exit 0
            ;;
        display-numbers)
            tmux display-panes
            exit 0
            ;;
        clear-history)
            tmux clear-history
            exit 0
            ;;
        copy-mode)
            tmux copy-mode
            exit 0
            ;;
        respawn)
            tmux respawn-pane -k
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
                --no-separator \
                --no-preview \
                --header-first \
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
                --no-separator \
                --no-preview \
                --header-first \
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
                --no-separator \
                --no-preview \
                --header-first \
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
            if [[ "$action_key" == "tab" ]]; then
                # Tab — pick a pane to kill
                get_tmux_option "$HUCKLEBERRY_PANE_KILL_PICK_PROMPT" "$HUCKLEBERRY_PANE_KILL_PICK_PROMPT_DEFAULT"; kill_prompt="$REPLY"
                get_tmux_option "$HUCKLEBERRY_PANE_KILL_PICK_HEADER" "$HUCKLEBERRY_PANE_KILL_PICK_HEADER_DEFAULT"; kill_header="$REPLY"

                pane_list=$(tmux list-panes \
                    -F '#{pane_index}::#{pane_index}: #{pane_current_command} (#{pane_width}x#{pane_height})')

                if [[ -z "$pane_list" ]]; then
                    continue
                fi

                if ! pane_selection=$(echo "$pane_list" | fzf \
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

                pane_index="${pane_selection%%::*}"
                tmux kill-pane -t "$pane_index"
            else
                # Enter — kill current pane
                tmux kill-pane
            fi
            exit 0
            ;;
    esac
done
