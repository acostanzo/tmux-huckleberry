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
get_tmux_option "$HUCKLEBERRY_SESSION_MGMT_FOOTER" "$HUCKLEBERRY_SESSION_MGMT_FOOTER_DEFAULT"; footer="$REPLY"
get_tmux_option "$HUCKLEBERRY_HEADER_BORDER" "$HUCKLEBERRY_HEADER_BORDER_DEFAULT"; header_border="$REPLY"
get_tmux_option "$HUCKLEBERRY_FOOTER_BORDER" "$HUCKLEBERRY_FOOTER_BORDER_DEFAULT"; footer_border="$REPLY"

header_border_args=(--header-border)
[[ -n "$header_border" ]] && header_border_args=(--header-border "$header_border")
footer_border_args=(--footer-border)
[[ -n "$footer_border" ]] && footer_border_args=(--footer-border "$footer_border")

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
            get_tmux_option "$HUCKLEBERRY_SES_RENAME_PROMPT" "$HUCKLEBERRY_SES_RENAME_PROMPT_DEFAULT"; rename_prompt="$REPLY"
            get_tmux_option "$HUCKLEBERRY_SES_RENAME_HEADER" "$HUCKLEBERRY_SES_RENAME_HEADER_DEFAULT"; rename_header="$REPLY"

            current_name=$(tmux display-message -p '#{session_name}')

            rename_output=$(: | fzf \
                --print-query \
                --reverse \
                --no-info \
                --no-separator \
                --no-preview \
                --header-first \
                --query "$current_name" \
                --prompt "$rename_prompt" \
                --header "$rename_header")

            rename_exit=$?

            if [[ $rename_exit -eq 130 ]]; then
                continue
            fi

            IFS= read -r new_name <<< "$rename_output"

            if [[ -n "$new_name" ]]; then
                if ! valid_session_name "$new_name"; then
                    tmux display-message "Invalid session name (cannot contain ':' or '.')"
                    continue
                fi
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
                --no-separator \
                --no-preview \
                --header-first \
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

            new_output=$(: | fzf \
                --print-query \
                --reverse \
                --no-info \
                --no-separator \
                --no-preview \
                --header-first \
                --prompt "$new_prompt" \
                --header "$new_header")

            new_exit=$?

            if [[ $new_exit -eq 130 ]]; then
                continue
            fi

            IFS= read -r name <<< "$new_output"

            if [[ -z "$name" ]]; then
                continue
            fi

            if ! valid_session_name "$name"; then
                tmux display-message "Invalid session name (cannot contain ':' or '.')"
                continue
            fi

            if tmux has-session -t "=$name" 2>/dev/null; then
                tmux switch-client -t "=$name"
            else
                tmux new-session -d -s "$name"
                tmux set-window-option -t "=$name" automatic-rename off
                tmux rename-window -t "=$name" -- "$name"
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
