#!/usr/bin/env bash
# shellcheck disable=SC1091  # sourced files are resolved at runtime
# Session management sub-palette — session admin actions via fzf.
# Uses a while-true loop so Escape in sub-pickers returns to the action list.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=common.sh
source "${CURRENT_DIR}/common.sh"

strip_fzf_opts

get_tmux_option "$HUCKLEBERRY_SESSION_MGMT_PROMPT" "$HUCKLEBERRY_SESSION_MGMT_PROMPT_DEFAULT"; prompt="$REPLY"
get_tmux_option "$HUCKLEBERRY_SESSION_MGMT_HEADER" "$HUCKLEBERRY_SESSION_MGMT_HEADER_DEFAULT"; header="$REPLY"

get_tmux_option "$HUCKLEBERRY_SES_RENAME" "$HUCKLEBERRY_SES_RENAME_DEFAULT"; rename_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_SES_KILL" "$HUCKLEBERRY_SES_KILL_DEFAULT"; kill_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_SES_NEW" "$HUCKLEBERRY_SES_NEW_DEFAULT"; new_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_SES_DETACH" "$HUCKLEBERRY_SES_DETACH_DEFAULT"; detach_label="$REPLY"

# --- Build action list --------------------------------------------------------

actions="rename::${rename_label}"
actions+=$'\n'"kill::${kill_label}"
actions+=$'\n'"new::${new_label}"
actions+=$'\n'"detach::${detach_label}"

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
        rename)
            get_tmux_option "$HUCKLEBERRY_SES_RENAME_PROMPT" "$HUCKLEBERRY_SES_RENAME_PROMPT_DEFAULT"; rename_prompt="$REPLY"
            get_tmux_option "$HUCKLEBERRY_SES_RENAME_HEADER" "$HUCKLEBERRY_SES_RENAME_HEADER_DEFAULT"; rename_header="$REPLY"

            current_name=$(tmux display-message -p '#{session_name}')

            new_name=$(: | fzf \
                --print-query \
                --reverse \
                --no-info \
                --no-preview \
                --query "$current_name" \
                --prompt "$rename_prompt" \
                --header "$rename_header" \
                | head -1)

            rename_exit=$?

            if [[ $rename_exit -ne 0 ]]; then
                continue
            fi

            if [[ -n "$new_name" ]]; then
                tmux rename-session -- "$new_name"
            fi
            exit 0
            ;;
        kill)
            get_tmux_option "$HUCKLEBERRY_SES_KILL_PROMPT" "$HUCKLEBERRY_SES_KILL_PROMPT_DEFAULT"; kill_prompt="$REPLY"
            get_tmux_option "$HUCKLEBERRY_SES_KILL_HEADER" "$HUCKLEBERRY_SES_KILL_HEADER_DEFAULT"; kill_header="$REPLY"

            current_session=$(tmux display-message -p '#{session_name}')
            session_list=$(tmux list-sessions -F '#{session_name}' \
                | while IFS= read -r name; do
                    if [[ "$name" != "$current_session" ]]; then
                        echo "$name"
                    fi
                done)

            if [[ -z "$session_list" ]]; then
                tmux display-message "No other sessions"
                continue
            fi

            target=$(echo "$session_list" | fzf \
                --reverse \
                --no-info \
                --no-preview \
                --prompt "$kill_prompt" \
                --header "$kill_header")

            kill_exit=$?

            if [[ $kill_exit -ne 0 ]]; then
                continue
            fi

            tmux kill-session -t "=$target"
            exit 0
            ;;
        new)
            get_tmux_option "$HUCKLEBERRY_SES_NEW_PROMPT" "$HUCKLEBERRY_SES_NEW_PROMPT_DEFAULT"; new_prompt="$REPLY"
            get_tmux_option "$HUCKLEBERRY_SES_NEW_HEADER" "$HUCKLEBERRY_SES_NEW_HEADER_DEFAULT"; new_header="$REPLY"

            name=$(: | fzf \
                --print-query \
                --reverse \
                --no-info \
                --no-preview \
                --prompt "$new_prompt" \
                --header "$new_header" \
                | head -1)

            new_exit=$?

            if [[ $new_exit -ne 0 ]]; then
                continue
            fi

            if [[ -z "$name" ]]; then
                continue
            fi

            if tmux has-session -t "=$name" 2>/dev/null; then
                tmux switch-client -t "=$name"
            else
                tmux new-session -d -s "$name"
                tmux set-window-option -t "=$name" automatic-rename off
                tmux rename-window -t "=$name" "$name"
                tmux switch-client -t "=$name"
            fi
            exit 0
            ;;
        detach)
            tmux detach-client -a
            exit 0
            ;;
    esac
done
