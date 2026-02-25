#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2154  # sourced files; helper-set vars
# Buffers sub-palette — clipboard/buffer management actions via fzf.
# Uses a while-true loop so Escape in sub-pickers returns to the action list.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=common.sh
source "${CURRENT_DIR}/common.sh"

strip_fzf_opts

get_tmux_option "$HUCKLEBERRY_BUFFERS_PROMPT" "$HUCKLEBERRY_BUFFERS_PROMPT_DEFAULT"; prompt="$REPLY"
get_tmux_option "$HUCKLEBERRY_BUFFERS_HEADER" "$HUCKLEBERRY_BUFFERS_HEADER_DEFAULT"; header="$REPLY"
get_tmux_option "$HUCKLEBERRY_BUFFERS_FOOTER" "$HUCKLEBERRY_BUFFERS_FOOTER_DEFAULT"; footer="$REPLY"
get_tmux_option "$HUCKLEBERRY_HEADER_BORDER" "$HUCKLEBERRY_HEADER_BORDER_DEFAULT"; header_border="$REPLY"
get_tmux_option "$HUCKLEBERRY_FOOTER_BORDER" "$HUCKLEBERRY_FOOTER_BORDER_DEFAULT"; footer_border="$REPLY"

header_border_args=(--header-border)
[[ -n "$header_border" ]] && header_border_args=(--header-border "$header_border")
footer_border_args=(--footer-border)
[[ -n "$footer_border" ]] && footer_border_args=(--footer-border "$footer_border")

get_tmux_option "$HUCKLEBERRY_BUF_PASTE" "$HUCKLEBERRY_BUF_PASTE_DEFAULT"; paste_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_BUF_CHOOSE" "$HUCKLEBERRY_BUF_CHOOSE_DEFAULT"; choose_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_BUF_CAPTURE" "$HUCKLEBERRY_BUF_CAPTURE_DEFAULT"; capture_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_BUF_DELETE" "$HUCKLEBERRY_BUF_DELETE_DEFAULT"; delete_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_BUF_SAVE" "$HUCKLEBERRY_BUF_SAVE_DEFAULT"; save_label="$REPLY"

# --- Build action list --------------------------------------------------------

actions="paste::${paste_label}"
actions+=$'\n'"choose::${choose_label}"
actions+=$'\n'"capture::${capture_label}"
actions+=$'\n'"delete::${delete_label}"
actions+=$'\n'"save::${save_label}"

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
        --expect="$_huck_expect_keys" \
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

    # Resolve number hotkeys to action IDs.
    _huck_resolve_hotkey "$action_key" "$selection"
    action="$REPLY"

    case "$action" in
        paste)
            tmux paste-buffer
            exit 0
            ;;
        choose)
            get_tmux_option "$HUCKLEBERRY_BUF_CHOOSE_PROMPT" "$HUCKLEBERRY_BUF_CHOOSE_PROMPT_DEFAULT"; choose_prompt="$REPLY"
            get_tmux_option "$HUCKLEBERRY_BUF_CHOOSE_HEADER" "$HUCKLEBERRY_BUF_CHOOSE_HEADER_DEFAULT"; choose_header="$REPLY"
            get_tmux_option "$HUCKLEBERRY_BUF_CHOOSE_PREVIEW" "$HUCKLEBERRY_BUF_CHOOSE_PREVIEW_DEFAULT"; choose_preview="$REPLY"

            buf_list=$(tmux list-buffers -F '#{buffer_name}::#{buffer_name}: #{buffer_size} bytes' 2>/dev/null)

            if [[ -z "$buf_list" ]]; then
                tmux display-message "No buffers"
                continue
            fi

            # Preview shows buffer contents. The {} placeholder is the full
            # line (name::label); we extract the buffer name before the ::.
            # shellcheck disable=SC2016
            buf_selection=$(echo "$buf_list" | SHELL="$BASH" fzf \
                --reverse \
                --no-info \
                --no-separator \
                --header-first \
                --delimiter '::' \
                --with-nth 2 \
                --prompt "$choose_prompt" \
                --header "$choose_header" \
                --preview 'name={}; name="${name%%::*}"; tmux show-buffer -b "$name" 2>/dev/null' \
                --preview-window "$choose_preview")

            buf_exit=$?

            if [[ $buf_exit -ne 0 ]]; then
                continue
            fi

            buf_name="${buf_selection%%::*}"
            tmux paste-buffer -b "$buf_name"
            exit 0
            ;;
        capture)
            tmux capture-pane
            tmux display-message "Pane captured to buffer"
            exit 0
            ;;
        delete)
            get_tmux_option "$HUCKLEBERRY_BUF_DELETE_PROMPT" "$HUCKLEBERRY_BUF_DELETE_PROMPT_DEFAULT"; delete_prompt="$REPLY"
            get_tmux_option "$HUCKLEBERRY_BUF_DELETE_HEADER" "$HUCKLEBERRY_BUF_DELETE_HEADER_DEFAULT"; delete_header="$REPLY"

            buf_list=$(tmux list-buffers -F '#{buffer_name}::#{buffer_name}: #{buffer_size} bytes' 2>/dev/null)

            if [[ -z "$buf_list" ]]; then
                tmux display-message "No buffers"
                continue
            fi

            buf_selection=$(echo "$buf_list" | fzf \
                --reverse \
                --no-info \
                --no-separator \
                --no-preview \
                --header-first \
                --delimiter '::' \
                --with-nth 2 \
                --prompt "$delete_prompt" \
                --header "$delete_header")

            buf_exit=$?

            if [[ $buf_exit -ne 0 ]]; then
                continue
            fi

            buf_name="${buf_selection%%::*}"
            tmux delete-buffer -b "$buf_name"
            exit 0
            ;;
        save)
            get_tmux_option "$HUCKLEBERRY_BUF_SAVE_PROMPT" "$HUCKLEBERRY_BUF_SAVE_PROMPT_DEFAULT"; save_prompt="$REPLY"
            get_tmux_option "$HUCKLEBERRY_BUF_SAVE_HEADER" "$HUCKLEBERRY_BUF_SAVE_HEADER_DEFAULT"; save_header="$REPLY"

            save_output=$(: | fzf \
                --print-query \
                --reverse \
                --no-info \
                --no-separator \
                --no-preview \
                --header-first \
                --prompt "$save_prompt" \
                --header "$save_header")

            save_exit=$?

            if [[ $save_exit -eq 130 ]]; then
                continue
            fi

            IFS= read -r save_path <<< "$save_output"

            if [[ -n "$save_path" ]]; then
                # Expand leading tilde (tmux doesn't expand ~).
                save_path="${save_path/#\~/$HOME}"
                tmux save-buffer "$save_path"
                tmux display-message "Buffer saved to ${save_path}"
            fi
            exit 0
            ;;
    esac
done
