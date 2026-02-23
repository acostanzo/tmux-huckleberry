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

# --- Build action list --------------------------------------------------------

actions="rename::${rename_label}"

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
    esac
done
