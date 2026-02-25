#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2154  # sourced files; helper-set vars
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
get_tmux_option "$HUCKLEBERRY_SES_LIST_CLIENTS" "$HUCKLEBERRY_SES_LIST_CLIENTS_DEFAULT"; list_clients_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_SES_DETACH_CLIENT" "$HUCKLEBERRY_SES_DETACH_CLIENT_DEFAULT"; detach_client_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_SES_DETACH" "$HUCKLEBERRY_SES_DETACH_DEFAULT"; detach_label="$REPLY"

# --- Build action list --------------------------------------------------------

actions="new::${new_label}"
actions+=$'\n'"rename::${rename_label}"
actions+=$'\n'"list-clients::${list_clients_label}"
actions+=$'\n'"detach-client::${detach_client_label}"
actions+=$'\n'"detach::${detach_label}"
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
            get_tmux_option "$HUCKLEBERRY_SES_RENAME_PROMPT" "$HUCKLEBERRY_SES_RENAME_PROMPT_DEFAULT"; rename_prompt="$REPLY"
            get_tmux_option "$HUCKLEBERRY_SES_RENAME_HEADER" "$HUCKLEBERRY_SES_RENAME_HEADER_DEFAULT"; rename_header="$REPLY"

            target=""
            prefill=$(tmux display-message -p '#{session_name}')

            if [[ "$action_key" == "tab" ]]; then
                # Tab — pick a session to rename
                get_tmux_option "$HUCKLEBERRY_SES_RENAME_PICK_PROMPT" "$HUCKLEBERRY_SES_RENAME_PICK_PROMPT_DEFAULT"; pick_prompt="$REPLY"
                get_tmux_option "$HUCKLEBERRY_SES_RENAME_PICK_HEADER" "$HUCKLEBERRY_SES_RENAME_PICK_HEADER_DEFAULT"; pick_header="$REPLY"

                session_list=$(tmux list-sessions -F '#{session_name}')

                if [[ -z "$session_list" ]]; then
                    continue
                fi

                if ! target=$(echo "$session_list" | fzf \
                    --reverse \
                    --no-info \
                    --no-separator \
                    --no-preview \
                    --header-first \
                    --prompt "$pick_prompt" \
                    --header "$pick_header"); then
                    continue
                fi

                prefill="$target"
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

            IFS= read -r new_name <<< "$rename_output"

            if [[ -n "$new_name" ]]; then
                if ! valid_session_name "$new_name"; then
                    tmux display-message "Invalid session name (cannot contain ':' or '.')"
                    continue
                fi
                if [[ -n "$target" ]]; then
                    tmux rename-session -t "=$target" -- "$new_name"
                else
                    tmux rename-session -- "$new_name"
                fi
            fi
            exit 0
            ;;
        kill)
            if [[ "$action_key" == "tab" ]]; then
                # Tab — pick a session to kill
                get_tmux_option "$HUCKLEBERRY_SES_KILL_PROMPT" "$HUCKLEBERRY_SES_KILL_PROMPT_DEFAULT"; kill_prompt="$REPLY"
                get_tmux_option "$HUCKLEBERRY_SES_KILL_HEADER" "$HUCKLEBERRY_SES_KILL_HEADER_DEFAULT"; kill_header="$REPLY"

                session_list=$(tmux list-sessions -F '#{session_name}')

                if [[ -z "$session_list" ]]; then
                    tmux display-message "No sessions"
                    continue
                fi

                if ! target=$(echo "$session_list" | fzf \
                    --reverse \
                    --no-info \
                    --no-separator \
                    --no-preview \
                    --header-first \
                    --prompt "$kill_prompt" \
                    --header "$kill_header"); then
                    continue
                fi

                tmux kill-session -t "=$target"
            else
                # Enter — kill current session
                tmux kill-session
            fi
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
        list-clients)
            get_tmux_option "$HUCKLEBERRY_SES_LIST_CLIENTS_PROMPT" "$HUCKLEBERRY_SES_LIST_CLIENTS_PROMPT_DEFAULT"; lc_prompt="$REPLY"
            get_tmux_option "$HUCKLEBERRY_SES_LIST_CLIENTS_HEADER" "$HUCKLEBERRY_SES_LIST_CLIENTS_HEADER_DEFAULT"; lc_header="$REPLY"

            client_list=$(tmux list-clients -F '#{client_name}: #{session_name} (#{client_width}x#{client_height})' 2>/dev/null)

            if [[ -z "$client_list" ]]; then
                tmux display-message "No clients attached"
                continue
            fi

            # Read-only fzf browser — no action on selection, Escape goes back.
            echo "$client_list" | fzf \
                --reverse \
                --no-info \
                --no-separator \
                --no-preview \
                --header-first \
                --prompt "$lc_prompt" \
                --header "$lc_header" > /dev/null

            continue
            ;;
        detach-client)
            get_tmux_option "$HUCKLEBERRY_SES_DETACH_CLIENT_PROMPT" "$HUCKLEBERRY_SES_DETACH_CLIENT_PROMPT_DEFAULT"; dc_prompt="$REPLY"
            get_tmux_option "$HUCKLEBERRY_SES_DETACH_CLIENT_HEADER" "$HUCKLEBERRY_SES_DETACH_CLIENT_HEADER_DEFAULT"; dc_header="$REPLY"

            client_list=$(tmux list-clients -F '#{client_name}::#{client_name}: #{session_name} (#{client_width}x#{client_height})' 2>/dev/null)

            if [[ -z "$client_list" ]]; then
                tmux display-message "No clients attached"
                continue
            fi

            if ! client_selection=$(echo "$client_list" | fzf \
                --reverse \
                --no-info \
                --no-separator \
                --no-preview \
                --header-first \
                --delimiter '::' \
                --with-nth 2 \
                --prompt "$dc_prompt" \
                --header "$dc_header"); then
                continue
            fi

            client_name="${client_selection%%::*}"
            tmux detach-client -t "$client_name"
            exit 0
            ;;
        detach)
            tmux detach-client -a
            exit 0
            ;;
    esac
done
