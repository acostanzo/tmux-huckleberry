#!/usr/bin/env bash
# shellcheck disable=SC1091  # sourced files are resolved at runtime
# Session palette — lists sessions through fzf; switch to selection or create a new one.
# Tab on a session drills into a nested window picker for that session.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=common.sh
source "${CURRENT_DIR}/common.sh"

strip_fzf_opts

get_tmux_option "$HUCKLEBERRY_PROMPT" "$HUCKLEBERRY_PROMPT_DEFAULT"; prompt="$REPLY"
get_tmux_option "$HUCKLEBERRY_HEADER" "$HUCKLEBERRY_HEADER_DEFAULT"; header="$REPLY"
get_tmux_option "$HUCKLEBERRY_PREVIEW" "$HUCKLEBERRY_PREVIEW_DEFAULT"; preview="$REPLY"
get_tmux_option "$HUCKLEBERRY_MARKER" "$HUCKLEBERRY_MARKER_DEFAULT"; marker="$REPLY"
get_tmux_option "$HUCKLEBERRY_PREVIEW_FMT" "$HUCKLEBERRY_PREVIEW_FMT_DEFAULT"; preview_fmt="$REPLY"
get_tmux_option "$HUCKLEBERRY_TAB_HINT" "$HUCKLEBERRY_TAB_HINT_DEFAULT"; tab_hint="$REPLY"
get_tmux_option "$HUCKLEBERRY_SESSION_WINDOWS_PROMPT" "$HUCKLEBERRY_SESSION_WINDOWS_PROMPT_DEFAULT"; win_prompt="$REPLY"
get_tmux_option "$HUCKLEBERRY_SESSION_WINDOWS_HEADER" "$HUCKLEBERRY_SESSION_WINDOWS_HEADER_DEFAULT"; win_header="$REPLY"
get_tmux_option "$HUCKLEBERRY_SESSION_WINDOWS_FMT" "$HUCKLEBERRY_SESSION_WINDOWS_FMT_DEFAULT"; win_fmt="$REPLY"

current_session="$(tmux display-message -p '#{session_name}')"

# Pad unmarked entries to align with the marker width.
printf -v padding '%*s' "${#marker}" ''

# Export the preview format so fzf's preview subshell can see it.
export HUCK_PREVIEW_FMT="$preview_fmt"

# Build the session list, marking the current session with a prefix.
session_list() {
    tmux list-sessions -F '#{session_name}' | while IFS= read -r name; do
        if [[ "$name" == "$current_session" ]]; then
            echo "${marker}${name}"
        else
            echo "${padding}${name}"
        fi
    done
}

# Combine header and tab hint for display.
full_header="${header}
${tab_hint}"

# --- Main loop — Tab drills into windows, Escape returns to dispatcher -------

while true; do
    # Run fzf and capture output.
    # --print-query + --expect=tab puts three lines: query, key, selection.
    # The preview string is intentionally single-quoted so fzf evaluates it per-line.
    # shellcheck disable=SC2016
    fzf_output=$(session_list | SHELL="$BASH" fzf \
        --print-query \
        --expect=tab \
        --reverse \
        --no-info \
        --prompt "$prompt" \
        --header "$full_header" \
        --preview 'name={}; name="${name#"${name%%[a-zA-Z0-9]*}"}"; tmux list-windows -t "=$name" -F "$HUCK_PREVIEW_FMT" 2>/dev/null' \
        --preview-window "$preview")

    fzf_exit=$?

    # Parse three output lines with bash read (no subprocess).
    {
        IFS= read -r query
        IFS= read -r key
        IFS= read -r selection
    } <<< "$fzf_output"

    # Escape pressed — return to top-level menu (or exit if run directly).
    if [[ $fzf_exit -eq 130 ]]; then
        # shellcheck disable=SC2317
        return 0 2>/dev/null || exit 0
    fi

    # --- Tab: drill into window picker for the selected session ---------------

    if [[ "$key" == "tab" && -n "$selection" ]]; then
        # Strip the marker or padding prefix to get the bare session name.
        target="${selection#"$marker"}"
        target="${target#"$padding"}"

        # Build window list using the id::label pattern.
        win_list=$(tmux list-windows -t "=$target" -F "#{window_index}::${win_fmt}" 2>/dev/null)

        if [[ -z "$win_list" ]]; then
            continue
        fi

        win_selection=$(echo "$win_list" | fzf \
            --reverse \
            --no-info \
            --no-preview \
            --delimiter '::' \
            --with-nth 2 \
            --prompt "$win_prompt" \
            --header "$win_header")

        win_exit=$?

        # Escape from window picker — back to session list.
        if [[ $win_exit -ne 0 ]]; then
            continue
        fi

        # Extract the window index (everything before the first "::").
        win_index="${win_selection%%::*}"
        tmux switch-client -t "=$target:=$win_index"
        exit 0
    fi

    # --- Enter: switch to selected session or create a new one ----------------

    if [[ -n "$selection" ]]; then
        # Strip the marker or padding prefix to get the bare session name.
        target="${selection#"$marker"}"
        target="${target#"$padding"}"
        tmux switch-client -t "=$target"
        exit 0
    elif [[ -n "$query" ]]; then
        # No match selected — create a new session with the query as its name.
        if ! valid_session_name "$query"; then
            tmux display-message "Invalid session name (cannot contain ':' or '.')"
            # shellcheck disable=SC2317
            return 0 2>/dev/null || exit 0
        fi
        if tmux has-session -t "=$query" 2>/dev/null; then
            tmux switch-client -t "=$query"
        else
            tmux new-session -d -s "$query"
            tmux set-window-option -t "=$query" automatic-rename off
            tmux rename-window -t "=$query" -- "$query"
            tmux switch-client -t "=$query"
        fi
        exit 0
    fi
done
