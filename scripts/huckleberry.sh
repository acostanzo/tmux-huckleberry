#!/usr/bin/env bash
# shellcheck disable=SC1091  # sourced files are resolved at runtime
# Top-level command palette dispatcher — runs inside the tmux popup.
# Shows categories via fzf; hotkeys or Enter route to sub-palettes.
# Sub-palettes return here on Escape; the loop re-shows the menu.

shopt -s extglob

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=helpers.sh
source "${CURRENT_DIR}/helpers.sh"
# shellcheck source=variables.sh
source "${CURRENT_DIR}/variables.sh"

# --- Read category options (once) --------------------------------------------

get_tmux_option "$HUCKLEBERRY_MENU_PROMPT" "$HUCKLEBERRY_MENU_PROMPT_DEFAULT"; menu_prompt="$REPLY"
get_tmux_option "$HUCKLEBERRY_MENU_HEADER" "$HUCKLEBERRY_MENU_HEADER_DEFAULT"; menu_header="$REPLY"
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

get_tmux_option "$HUCKLEBERRY_CAT_CONFIG_KEY" "$HUCKLEBERRY_CAT_CONFIG_KEY_DEFAULT"; config_key="$REPLY"
get_tmux_option "$HUCKLEBERRY_CAT_CONFIG_LABEL" "$HUCKLEBERRY_CAT_CONFIG_LABEL_DEFAULT"; config_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_CAT_CONFIG_DESC" "$HUCKLEBERRY_CAT_CONFIG_DESC_DEFAULT"; config_desc="$REPLY"

# --- Build display keys (render "space" as the configurable display char) ----

if [[ "$sessions_key" == "space" ]]; then sessions_display="$space_display"; else sessions_display="$sessions_key"; fi
if [[ "$windows_key" == "space" ]]; then windows_display="$space_display"; else windows_display="$windows_key"; fi
if [[ "$panes_key" == "space" ]]; then panes_display="$space_display"; else panes_display="$panes_key"; fi
if [[ "$config_key" == "space" ]]; then config_display="$space_display"; else config_display="$config_key"; fi

# --- Build menu (pure string concat, no subshell) ----------------------------

printf -v menu '%s\n%s\n%s\n%s' \
    "  ${sessions_display}  ${sessions_label}     ${sessions_desc}" \
    "  ${windows_display}  ${windows_label}      ${windows_desc}" \
    "  ${panes_display}  ${panes_label}       ${panes_desc}" \
    "  ${config_display}  ${config_label}       ${config_desc}"

# --- Strip conflicting FZF_DEFAULT_OPTS (bash builtins, no subprocess) -------

FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS//--height=*([^ ])/}"
FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS//--border*([^ ])/}"
export FZF_DEFAULT_OPTS

# --- Main loop — sub-palettes return here on Escape -------------------------
# Save the scripts dir — sub-palettes overwrite CURRENT_DIR when sourced.
_dispatcher_dir="$CURRENT_DIR"

while true; do
    fzf_output=$(echo "$menu" | fzf \
        --print-query \
        --expect="${sessions_key},${windows_key},${panes_key},${config_key}" \
        --reverse \
        --no-info \
        --no-preview \
        --prompt "$menu_prompt" \
        --header "$menu_header")

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
    elif [[ "$key" == "$windows_key" ]]; then
        palette="windows"
    elif [[ "$key" == "$panes_key" ]]; then
        palette="panes"
    elif [[ "$key" == "$config_key" ]]; then
        palette="config"
    elif [[ -n "$selection" ]]; then
        # Enter pressed — match by label in the selection string.
        if [[ "$selection" == *"$sessions_label"* ]]; then
            palette="sessions"
        elif [[ "$selection" == *"$windows_label"* ]]; then
            palette="windows"
        elif [[ "$selection" == *"$panes_label"* ]]; then
            palette="panes"
        elif [[ "$selection" == *"$config_label"* ]]; then
            palette="config"
        fi
    fi

    if [[ -n "$palette" ]]; then
        # shellcheck source=/dev/null
        source "${_dispatcher_dir}/palettes/${palette}.sh"
        # If the sub-palette returned (Escape), the loop re-shows the menu.
        # If the sub-palette exited (action completed), the process is gone.
    fi
done
