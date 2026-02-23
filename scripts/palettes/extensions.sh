#!/usr/bin/env bash
# shellcheck disable=SC1091  # sourced files are resolved at runtime
# Extensions sub-palette — two-level drill-down: extension list → action list → execute.
# Only reachable when @huckleberry-extensions is non-empty (dispatcher guards this).

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=common.sh
source "${CURRENT_DIR}/common.sh"

strip_fzf_opts

# --- Read palette options (once) -----------------------------------------------

get_tmux_option "$HUCKLEBERRY_EXTENSIONS" ""; extensions_csv="$REPLY"
get_tmux_option "$HUCKLEBERRY_EXTENSIONS_PROMPT" "$HUCKLEBERRY_EXTENSIONS_PROMPT_DEFAULT"; extensions_prompt="$REPLY"
get_tmux_option "$HUCKLEBERRY_EXTENSIONS_HEADER" "$HUCKLEBERRY_EXTENSIONS_HEADER_DEFAULT"; extensions_header="$REPLY"
get_tmux_option "$HUCKLEBERRY_EXTENSIONS_FOOTER" "$HUCKLEBERRY_EXTENSIONS_FOOTER_DEFAULT"; extensions_footer="$REPLY"
get_tmux_option "$HUCKLEBERRY_EXTENSIONS_ACTIONS_PROMPT" "$HUCKLEBERRY_EXTENSIONS_ACTIONS_PROMPT_DEFAULT"; actions_prompt="$REPLY"
get_tmux_option "$HUCKLEBERRY_EXTENSIONS_ACTIONS_HEADER_PREFIX" "$HUCKLEBERRY_EXTENSIONS_ACTIONS_HEADER_PREFIX_DEFAULT"; actions_header_prefix="$REPLY"
get_tmux_option "$HUCKLEBERRY_EXTENSIONS_ACTIONS_FOOTER" "$HUCKLEBERRY_EXTENSIONS_ACTIONS_FOOTER_DEFAULT"; actions_footer="$REPLY"
get_tmux_option "$HUCKLEBERRY_HEADER_BORDER" "$HUCKLEBERRY_HEADER_BORDER_DEFAULT"; header_border="$REPLY"
get_tmux_option "$HUCKLEBERRY_FOOTER_BORDER" "$HUCKLEBERRY_FOOTER_BORDER_DEFAULT"; footer_border="$REPLY"

# --- Guard: no extensions configured -------------------------------------------

if [[ -z "$extensions_csv" ]]; then
    tmux display-message "huckleberry: no extensions configured — set @huckleberry-extensions"
    # shellcheck disable=SC2317
    return 0 2>/dev/null || exit 0
fi

# --- Build border args for fzf ------------------------------------------------

header_border_args=(--header-border)
[[ -n "$header_border" ]] && header_border_args=(--header-border "$header_border")
footer_border_args=(--footer-border)
[[ -n "$footer_border" ]] && footer_border_args=(--footer-border "$footer_border")

# --- Parse CSV into extension list (pure bash, no subshells) -------------------

ext_list=""
_remaining="$extensions_csv"
while [[ -n "$_remaining" ]]; do
    _id="${_remaining%%,*}"
    # Trim leading/trailing whitespace
    _id="${_id#"${_id%%[![:space:]]*}"}"
    _id="${_id%"${_id##*[![:space:]]}"}"
    if [[ -n "$_id" ]]; then
        get_tmux_option "@huckleberry-extension-${_id}-label" "$_id"; _label="$REPLY"
        if [[ -n "$ext_list" ]]; then
            ext_list+=$'\n'
        fi
        ext_list+="${_id}::${_label}"
    fi
    # Advance past the consumed item
    if [[ "$_remaining" == *,* ]]; then
        _remaining="${_remaining#*,}"
    else
        _remaining=""
    fi
done

if [[ -z "$ext_list" ]]; then
    tmux display-message "huckleberry: no valid extensions found in @huckleberry-extensions"
    # shellcheck disable=SC2317
    return 0 2>/dev/null || exit 0
fi

# --- Outer loop — extension picker ---------------------------------------------

while true; do
    ext_selection=$(echo "$ext_list" | fzf \
        --reverse \
        --no-info \
        --no-separator \
        --no-preview \
        --header-first \
        --delimiter '::' \
        --with-nth 2 \
        --prompt "$extensions_prompt" \
        --header "$extensions_header" \
        --footer "$extensions_footer" \
        "${header_border_args[@]}" \
        "${footer_border_args[@]}")

    fzf_exit=$?

    # Escape — return to top-level menu (or exit if run directly).
    if [[ $fzf_exit -ne 0 ]]; then
        # shellcheck disable=SC2317
        return 0 2>/dev/null || exit 0
    fi

    selected_id="${ext_selection%%::*}"
    selected_label="${ext_selection#*::}"

    # Read actions CSV for this extension
    get_tmux_option "@huckleberry-extension-${selected_id}-actions" ""; actions_csv="$REPLY"

    if [[ -z "$actions_csv" ]]; then
        tmux display-message "huckleberry: no actions for extension '${selected_id}'"
        continue
    fi

    # Build action list (pure bash CSV parse)
    action_list=""
    _remaining="$actions_csv"
    while [[ -n "$_remaining" ]]; do
        _aid="${_remaining%%,*}"
        _aid="${_aid#"${_aid%%[![:space:]]*}"}"
        _aid="${_aid%"${_aid##*[![:space:]]}"}"
        if [[ -n "$_aid" ]]; then
            get_tmux_option "@huckleberry-extension-${selected_id}-${_aid}-label" "$_aid"; _alabel="$REPLY"
            if [[ -n "$action_list" ]]; then
                action_list+=$'\n'
            fi
            action_list+="${_aid}::${_alabel}"
        fi
        if [[ "$_remaining" == *,* ]]; then
            _remaining="${_remaining#*,}"
        else
            _remaining=""
        fi
    done

    if [[ -z "$action_list" ]]; then
        tmux display-message "huckleberry: no valid actions for extension '${selected_id}'"
        continue
    fi

    # --- Inner loop — action picker for the selected extension -----------------

    while true; do
        action_selection=$(echo "$action_list" | fzf \
            --reverse \
            --no-info \
            --no-separator \
            --no-preview \
            --header-first \
            --delimiter '::' \
            --with-nth 2 \
            --prompt "$actions_prompt" \
            --header "${actions_header_prefix}${selected_label}" \
            --footer "$actions_footer" \
            "${header_border_args[@]}" \
            "${footer_border_args[@]}")

        action_exit=$?

        # Escape — back to extension list.
        if [[ $action_exit -ne 0 ]]; then
            break
        fi

        action_id="${action_selection%%::*}"

        get_tmux_option "@huckleberry-extension-${selected_id}-${action_id}-cmd" ""; cmd="$REPLY"

        if [[ -z "$cmd" ]]; then
            tmux display-message "huckleberry: no command for '${selected_id}/${action_id}'"
            continue
        fi

        # Execute the tmux command — intentionally unquoted for word splitting.
        # shellcheck disable=SC2086
        tmux $cmd
        exit 0
    done
done
