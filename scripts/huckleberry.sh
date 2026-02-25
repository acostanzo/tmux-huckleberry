#!/usr/bin/env bash
# shellcheck disable=SC1091  # sourced files are resolved at runtime
# Top-level command palette dispatcher — runs inside the tmux popup.
# Shows categories via fzf; hotkeys or Enter route to sub-palettes.
# Sub-palettes return here on Escape; the loop re-shows the menu.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=helpers.sh
source "${CURRENT_DIR}/helpers.sh"
# shellcheck source=variables.sh
source "${CURRENT_DIR}/variables.sh"

# --- Read category options (once) --------------------------------------------

get_tmux_option "$HUCKLEBERRY_MENU_PROMPT" "$HUCKLEBERRY_MENU_PROMPT_DEFAULT"; menu_prompt="$REPLY"
get_tmux_option "$HUCKLEBERRY_MENU_HEADER" "$HUCKLEBERRY_MENU_HEADER_DEFAULT"; menu_header="$REPLY"
get_tmux_option "$HUCKLEBERRY_MENU_FOOTER" "$HUCKLEBERRY_MENU_FOOTER_DEFAULT"; menu_footer="$REPLY"
get_tmux_option "$HUCKLEBERRY_HEADER_BORDER" "$HUCKLEBERRY_HEADER_BORDER_DEFAULT"; header_border="$REPLY"
get_tmux_option "$HUCKLEBERRY_FOOTER_BORDER" "$HUCKLEBERRY_FOOTER_BORDER_DEFAULT"; footer_border="$REPLY"
get_tmux_option "$HUCKLEBERRY_SPACE_DISPLAY" "$HUCKLEBERRY_SPACE_DISPLAY_DEFAULT"; space_display="$REPLY"

get_tmux_option "$HUCKLEBERRY_CAT_SESSIONS_KEY" "$HUCKLEBERRY_CAT_SESSIONS_KEY_DEFAULT"; sessions_key="$REPLY"
get_tmux_option "$HUCKLEBERRY_CAT_SESSIONS_LABEL" "$HUCKLEBERRY_CAT_SESSIONS_LABEL_DEFAULT"; sessions_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_CAT_SESSIONS_DESC" "$HUCKLEBERRY_CAT_SESSIONS_DESC_DEFAULT"; sessions_desc="$REPLY"

get_tmux_option "$HUCKLEBERRY_CAT_WINDOWS_KEY" "$HUCKLEBERRY_CAT_WINDOWS_KEY_DEFAULT"; windows_key="$REPLY"
get_tmux_option "$HUCKLEBERRY_CAT_WINDOWS_LABEL" "$HUCKLEBERRY_CAT_WINDOWS_LABEL_DEFAULT"; windows_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_CAT_WINDOWS_DESC" "$HUCKLEBERRY_CAT_WINDOWS_DESC_DEFAULT"; windows_desc="$REPLY"

get_tmux_option "$HUCKLEBERRY_CAT_PANES_KEY" "$HUCKLEBERRY_CAT_PANES_KEY_DEFAULT"; panes_key="$REPLY"
get_tmux_option "$HUCKLEBERRY_CAT_PANES_LABEL" "$HUCKLEBERRY_CAT_PANES_LABEL_DEFAULT"; panes_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_CAT_PANES_DESC" "$HUCKLEBERRY_CAT_PANES_DESC_DEFAULT"; panes_desc="$REPLY"

get_tmux_option "$HUCKLEBERRY_CAT_SESSION_MGMT_KEY" "$HUCKLEBERRY_CAT_SESSION_MGMT_KEY_DEFAULT"; session_mgmt_key="$REPLY"
get_tmux_option "$HUCKLEBERRY_CAT_SESSION_MGMT_LABEL" "$HUCKLEBERRY_CAT_SESSION_MGMT_LABEL_DEFAULT"; session_mgmt_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_CAT_SESSION_MGMT_DESC" "$HUCKLEBERRY_CAT_SESSION_MGMT_DESC_DEFAULT"; session_mgmt_desc="$REPLY"

get_tmux_option "$HUCKLEBERRY_CAT_TOGGLES_KEY" "$HUCKLEBERRY_CAT_TOGGLES_KEY_DEFAULT"; toggles_key="$REPLY"
get_tmux_option "$HUCKLEBERRY_CAT_TOGGLES_LABEL" "$HUCKLEBERRY_CAT_TOGGLES_LABEL_DEFAULT"; toggles_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_CAT_TOGGLES_DESC" "$HUCKLEBERRY_CAT_TOGGLES_DESC_DEFAULT"; toggles_desc="$REPLY"

get_tmux_option "$HUCKLEBERRY_CAT_CONFIG_KEY" "$HUCKLEBERRY_CAT_CONFIG_KEY_DEFAULT"; config_key="$REPLY"
get_tmux_option "$HUCKLEBERRY_CAT_CONFIG_LABEL" "$HUCKLEBERRY_CAT_CONFIG_LABEL_DEFAULT"; config_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_CAT_CONFIG_DESC" "$HUCKLEBERRY_CAT_CONFIG_DESC_DEFAULT"; config_desc="$REPLY"

get_tmux_option "$HUCKLEBERRY_CAT_EXTENSIONS_KEY" "$HUCKLEBERRY_CAT_EXTENSIONS_KEY_DEFAULT"; extensions_key="$REPLY"
get_tmux_option "$HUCKLEBERRY_CAT_EXTENSIONS_LABEL" "$HUCKLEBERRY_CAT_EXTENSIONS_LABEL_DEFAULT"; extensions_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_CAT_EXTENSIONS_DESC" "$HUCKLEBERRY_CAT_EXTENSIONS_DESC_DEFAULT"; extensions_desc="$REPLY"
get_tmux_option "$HUCKLEBERRY_EXTENSIONS" ""; extensions_list="$REPLY"

# --- Warn on duplicate category keys ------------------------------------------

_huck_seen_keys=" "
_huck_dup=0
_huck_dup_keys=("$sessions_key" "$session_mgmt_key" "$windows_key" "$panes_key" "$toggles_key" "$config_key")
[[ -n "$extensions_list" ]] && _huck_dup_keys+=("$extensions_key")
for _k in "${_huck_dup_keys[@]}"; do
    if [[ "$_huck_seen_keys" == *" ${_k} "* ]]; then
        _huck_dup=1
        break
    fi
    _huck_seen_keys+="${_k} "
done
if [[ "$_huck_dup" -eq 1 ]]; then
    tmux display-message "huckleberry: duplicate category keys detected — check @huckleberry-cat-*-key options"
fi

# --- Build display keys (render "space" as the configurable display char) ----

if [[ "$sessions_key" == "space" ]]; then sessions_display="$space_display"; else sessions_display="$sessions_key"; fi
if [[ "$session_mgmt_key" == "space" ]]; then session_mgmt_display="$space_display"; else session_mgmt_display="$session_mgmt_key"; fi
if [[ "$windows_key" == "space" ]]; then windows_display="$space_display"; else windows_display="$windows_key"; fi
if [[ "$panes_key" == "space" ]]; then panes_display="$space_display"; else panes_display="$panes_key"; fi
if [[ "$toggles_key" == "space" ]]; then toggles_display="$space_display"; else toggles_display="$toggles_key"; fi
if [[ "$config_key" == "space" ]]; then config_display="$space_display"; else config_display="$config_key"; fi
if [[ "$extensions_key" == "space" ]]; then extensions_display="$space_display"; else extensions_display="$extensions_key"; fi

# --- Build menu (dynamically aligned, no subshell) ---------------------------

# Compute the max label width so the description column aligns for any labels.
max_label=${#sessions_label}
_label_list=("$session_mgmt_label" "$windows_label" "$panes_label" "$toggles_label" "$config_label")
[[ -n "$extensions_list" ]] && _label_list+=("$extensions_label")
for _l in "${_label_list[@]}"; do
    (( ${#_l} > max_label )) && max_label=${#_l}
done

printf -v menu '%s\n%s\n%s\n%s\n%s\n%s' \
    "$(printf '  %s  %-*s   %s' "$sessions_display" "$max_label" "$sessions_label" "$sessions_desc")" \
    "$(printf '  %s  %-*s   %s' "$session_mgmt_display" "$max_label" "$session_mgmt_label" "$session_mgmt_desc")" \
    "$(printf '  %s  %-*s   %s' "$windows_display" "$max_label" "$windows_label" "$windows_desc")" \
    "$(printf '  %s  %-*s   %s' "$panes_display" "$max_label" "$panes_label" "$panes_desc")" \
    "$(printf '  %s  %-*s   %s' "$toggles_display" "$max_label" "$toggles_label" "$toggles_desc")" \
    "$(printf '  %s  %-*s   %s' "$config_display" "$max_label" "$config_label" "$config_desc")"

if [[ -n "$extensions_list" ]]; then
    printf -v _extensions_row '  %s  %-*s   %s' "$extensions_display" "$max_label" "$extensions_label" "$extensions_desc"
    menu+=$'\n'"$_extensions_row"
fi

# --- Strip conflicting FZF_DEFAULT_OPTS --------------------------------------

strip_fzf_opts

# --- Build border args for fzf ------------------------------------------------

header_border_args=(--header-border)
[[ -n "$header_border" ]] && header_border_args=(--header-border "$header_border")
footer_border_args=(--footer-border)
[[ -n "$footer_border" ]] && footer_border_args=(--footer-border "$footer_border")

# --- Main loop — sub-palettes return here on Escape -------------------------
# Save the scripts dir — sub-palettes overwrite CURRENT_DIR when sourced.
_dispatcher_dir="$CURRENT_DIR"

while true; do
    _expect="${sessions_key},${session_mgmt_key},${windows_key},${panes_key},${toggles_key},${config_key}"
    [[ -n "$extensions_list" ]] && _expect+=",${extensions_key}"

    fzf_output=$(echo "$menu" | fzf \
        --print-query \
        --expect="$_expect" \
        --reverse \
        --no-info \
        --no-separator \
        --no-preview \
        --header-first \
        --prompt "$menu_prompt" \
        --header "$menu_header" \
        --footer "$menu_footer" \
        "${header_border_args[@]}" \
        "${footer_border_args[@]}")

    fzf_exit=$?

    # Parse output with bash read (no subprocess).
    {
        IFS= read -r _
        IFS= read -r key
        IFS= read -r selection
    } <<< "$fzf_output"

    # Escape at top level — close the popup.
    if [[ $fzf_exit -eq 130 ]]; then
        exit 0
    fi

    # --- Route to sub-palette ------------------------------------------------

    palette=""

    # Hotkey takes priority.
    if [[ "$key" == "$sessions_key" ]]; then
        palette="sessions"
    elif [[ "$key" == "$session_mgmt_key" ]]; then
        palette="session-mgmt"
    elif [[ "$key" == "$windows_key" ]]; then
        palette="windows"
    elif [[ "$key" == "$panes_key" ]]; then
        palette="panes"
    elif [[ "$key" == "$toggles_key" ]]; then
        palette="toggles"
    elif [[ "$key" == "$config_key" ]]; then
        palette="config"
    elif [[ -n "$extensions_list" && "$key" == "$extensions_key" ]]; then
        palette="extensions"
    elif [[ -n "$selection" ]]; then
        # Enter pressed — match by label in the selection string.
        if [[ "$selection" == *"$sessions_label"* ]]; then
            palette="sessions"
        elif [[ "$selection" == *"$session_mgmt_label"* ]]; then
            palette="session-mgmt"
        elif [[ "$selection" == *"$windows_label"* ]]; then
            palette="windows"
        elif [[ "$selection" == *"$panes_label"* ]]; then
            palette="panes"
        elif [[ "$selection" == *"$toggles_label"* ]]; then
            palette="toggles"
        elif [[ "$selection" == *"$config_label"* ]]; then
            palette="config"
        elif [[ -n "$extensions_list" && "$selection" == *"$extensions_label"* ]]; then
            palette="extensions"
        fi
    fi

    if [[ -n "$palette" ]]; then
        # shellcheck source=/dev/null
        source "${_dispatcher_dir}/palettes/${palette}.sh"
        # If the sub-palette returned (Escape), the loop re-shows the menu.
        # If the sub-palette exited (action completed), the process is gone.
    fi
done
