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

# --- Build action list --------------------------------------------------------

actions="select-layout::${select_layout_label}"

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
    esac
done
