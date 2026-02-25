#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2154  # sourced files; helper-set vars
# Toggles sub-palette — toggle common tmux options with live state indicators.
# The action list rebuilds each loop iteration to reflect current state.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=common.sh
source "${CURRENT_DIR}/common.sh"

strip_fzf_opts

get_tmux_option "$HUCKLEBERRY_TOGGLES_PROMPT" "$HUCKLEBERRY_TOGGLES_PROMPT_DEFAULT"; prompt="$REPLY"
get_tmux_option "$HUCKLEBERRY_TOGGLES_HEADER" "$HUCKLEBERRY_TOGGLES_HEADER_DEFAULT"; header="$REPLY"
get_tmux_option "$HUCKLEBERRY_TOGGLES_FOOTER" "$HUCKLEBERRY_TOGGLES_FOOTER_DEFAULT"; footer="$REPLY"
get_tmux_option "$HUCKLEBERRY_HEADER_BORDER" "$HUCKLEBERRY_HEADER_BORDER_DEFAULT"; header_border="$REPLY"
get_tmux_option "$HUCKLEBERRY_FOOTER_BORDER" "$HUCKLEBERRY_FOOTER_BORDER_DEFAULT"; footer_border="$REPLY"
get_tmux_option "$HUCKLEBERRY_TOGGLE_ON_INDICATOR" "$HUCKLEBERRY_TOGGLE_ON_INDICATOR_DEFAULT"; on_indicator="$REPLY"
get_tmux_option "$HUCKLEBERRY_TOGGLE_OFF_INDICATOR" "$HUCKLEBERRY_TOGGLE_OFF_INDICATOR_DEFAULT"; off_indicator="$REPLY"

header_border_args=(--header-border)
[[ -n "$header_border" ]] && header_border_args=(--header-border "$header_border")
footer_border_args=(--footer-border)
[[ -n "$footer_border" ]] && footer_border_args=(--footer-border "$footer_border")

get_tmux_option "$HUCKLEBERRY_TOGGLE_SYNC_PANES" "$HUCKLEBERRY_TOGGLE_SYNC_PANES_DEFAULT"; sync_panes_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_TOGGLE_MOUSE" "$HUCKLEBERRY_TOGGLE_MOUSE_DEFAULT"; mouse_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_TOGGLE_STATUS" "$HUCKLEBERRY_TOGGLE_STATUS_DEFAULT"; status_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_TOGGLE_PANE_BORDER" "$HUCKLEBERRY_TOGGLE_PANE_BORDER_DEFAULT"; pane_border_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_TOGGLE_MONITOR_ACTIVITY" "$HUCKLEBERRY_TOGGLE_MONITOR_ACTIVITY_DEFAULT"; monitor_activity_label="$REPLY"

# --- Helper: read current toggle state and set REPLY to indicator ----------
# Uses the REPLY variable pattern to avoid subshell forks from $(...).

_toggle_indicator() {
    if [[ "$1" == "on" || "$1" == "top" || "$1" == "bottom" ]]; then
        REPLY="$on_indicator"
    else
        REPLY="$off_indicator"
    fi
}

# --- Main loop — rebuilds action list each iteration for live state ---------

while true; do
    # Read current values for each toggle.
    sync_val=$(tmux show-window-option -v synchronize-panes 2>/dev/null)
    mouse_val=$(tmux show-option -gv mouse 2>/dev/null)
    status_val=$(tmux show-option -gv status 2>/dev/null)
    pane_border_val=$(tmux show-window-option -v pane-border-status 2>/dev/null)
    monitor_val=$(tmux show-window-option -v monitor-activity 2>/dev/null)

    _toggle_indicator "$sync_val";    actions="sync-panes::${sync_panes_label} ${REPLY}"
    _toggle_indicator "$mouse_val";  actions+=$'\n'"mouse::${mouse_label} ${REPLY}"
    _toggle_indicator "$status_val"; actions+=$'\n'"status::${status_label} ${REPLY}"
    _toggle_indicator "$pane_border_val"; actions+=$'\n'"pane-border::${pane_border_label} ${REPLY}"
    _toggle_indicator "$monitor_val"; actions+=$'\n'"monitor-activity::${monitor_activity_label} ${REPLY}"

    _huck_number_actions "$actions"
    actions="$REPLY"

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
        sync-panes)
            if [[ "$sync_val" == "on" ]]; then
                tmux set-window-option synchronize-panes off
            else
                tmux set-window-option synchronize-panes on
            fi
            # Loop back to show updated state.
            continue
            ;;
        mouse)
            if [[ "$mouse_val" == "on" ]]; then
                tmux set-option -g mouse off
            else
                tmux set-option -g mouse on
            fi
            continue
            ;;
        status)
            if [[ "$status_val" == "on" ]]; then
                tmux set-option -g status off
            else
                tmux set-option -g status on
            fi
            continue
            ;;
        pane-border)
            if [[ "$pane_border_val" == "off" ]]; then
                tmux set-window-option pane-border-status top
            else
                tmux set-window-option pane-border-status off
            fi
            continue
            ;;
        monitor-activity)
            if [[ "$monitor_val" == "on" ]]; then
                tmux set-window-option monitor-activity off
            else
                tmux set-window-option monitor-activity on
            fi
            continue
            ;;
    esac
done
