#!/usr/bin/env bash
# shellcheck disable=SC1091  # sourced files are resolved at runtime
# Core palette — runs inside the tmux popup.
# Lists sessions through fzf; switch to selection or create a new one.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=helpers.sh
source "${CURRENT_DIR}/helpers.sh"
# shellcheck source=variables.sh
source "${CURRENT_DIR}/variables.sh"

prompt=$(get_tmux_option "$HUCKLEBERRY_PROMPT" "$HUCKLEBERRY_PROMPT_DEFAULT")
current_session="$(tmux display-message -p '#{session_name}')"

# Build the session list, marking the current session with a prefix.
session_list() {
    tmux list-sessions -F '#{session_name}' | while IFS= read -r name; do
        if [[ "$name" == "$current_session" ]]; then
            echo "* ${name}"
        else
            echo "  ${name}"
        fi
    done
}

# Strip layout options from FZF_DEFAULT_OPTS that conflict with the popup:
#   --height: forces inline mode, leaving a gap at the bottom
#   --border: redundant with the tmux popup border
FZF_DEFAULT_OPTS=$(printf '%s' "$FZF_DEFAULT_OPTS" | sed 's/--height=[^ ]*//; s/--border[^ ]*//')
export FZF_DEFAULT_OPTS

# Run fzf and capture output.
# --print-query puts the raw query on line 1 and the selection on line 2.
# The preview string is intentionally single-quoted so fzf evaluates it per-line.
# shellcheck disable=SC2016
fzf_output=$(session_list | fzf \
    --print-query \
    --reverse \
    --no-info \
    --prompt "$prompt" \
    --header "  switch or create a session" \
    --preview 'tmux list-windows -t $(echo {} | sed "s/^[* ] //") 2>/dev/null' \
    --preview-window 'right:50%')

fzf_exit=$?

query=$(echo "$fzf_output" | head -n 1)
selection=$(echo "$fzf_output" | sed -n '2p')

# Escape pressed — exit cleanly.
if [[ $fzf_exit -eq 130 ]]; then
    exit 0
fi

if [[ -n "$selection" ]]; then
    # Strip the "* " or "  " prefix to get the bare session name.
    target="${selection#\* }"
    target="${target#  }"
    tmux switch-client -t "=$target"
elif [[ -n "$query" ]]; then
    # No match selected — create a new session with the query as its name.
    if tmux has-session -t "=$query" 2>/dev/null; then
        tmux switch-client -t "=$query"
    else
        tmux new-session -d -s "$query"
        tmux set-window-option -t "=$query" automatic-rename off
        tmux rename-window -t "=$query" "$query"
        tmux switch-client -t "=$query"
    fi
fi
