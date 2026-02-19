#!/usr/bin/env bash
# shellcheck disable=SC1091  # sourced files are resolved at runtime
# Top-level command palette dispatcher — runs inside the tmux popup.
# Shows categories via fzf; hotkeys or Enter route to sub-palettes.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=helpers.sh
source "${CURRENT_DIR}/helpers.sh"
# shellcheck source=variables.sh
source "${CURRENT_DIR}/variables.sh"

# --- Read category options ---------------------------------------------------

menu_prompt=$(get_tmux_option "$HUCKLEBERRY_MENU_PROMPT" "$HUCKLEBERRY_MENU_PROMPT_DEFAULT")
menu_header=$(get_tmux_option "$HUCKLEBERRY_MENU_HEADER" "$HUCKLEBERRY_MENU_HEADER_DEFAULT")
space_display=$(get_tmux_option "$HUCKLEBERRY_SPACE_DISPLAY" "$HUCKLEBERRY_SPACE_DISPLAY_DEFAULT")

sessions_key=$(get_tmux_option "$HUCKLEBERRY_CAT_SESSIONS_KEY" "$HUCKLEBERRY_CAT_SESSIONS_KEY_DEFAULT")
sessions_label=$(get_tmux_option "$HUCKLEBERRY_CAT_SESSIONS_LABEL" "$HUCKLEBERRY_CAT_SESSIONS_LABEL_DEFAULT")
sessions_desc=$(get_tmux_option "$HUCKLEBERRY_CAT_SESSIONS_DESC" "$HUCKLEBERRY_CAT_SESSIONS_DESC_DEFAULT")

windows_key=$(get_tmux_option "$HUCKLEBERRY_CAT_WINDOWS_KEY" "$HUCKLEBERRY_CAT_WINDOWS_KEY_DEFAULT")
windows_label=$(get_tmux_option "$HUCKLEBERRY_CAT_WINDOWS_LABEL" "$HUCKLEBERRY_CAT_WINDOWS_LABEL_DEFAULT")
windows_desc=$(get_tmux_option "$HUCKLEBERRY_CAT_WINDOWS_DESC" "$HUCKLEBERRY_CAT_WINDOWS_DESC_DEFAULT")

config_key=$(get_tmux_option "$HUCKLEBERRY_CAT_CONFIG_KEY" "$HUCKLEBERRY_CAT_CONFIG_KEY_DEFAULT")
config_label=$(get_tmux_option "$HUCKLEBERRY_CAT_CONFIG_LABEL" "$HUCKLEBERRY_CAT_CONFIG_LABEL_DEFAULT")
config_desc=$(get_tmux_option "$HUCKLEBERRY_CAT_CONFIG_DESC" "$HUCKLEBERRY_CAT_CONFIG_DESC_DEFAULT")

# --- Helpers -----------------------------------------------------------------

# Render the display character for a key name (e.g. "space" → "␣").
display_key() {
    if [[ "$1" == "space" ]]; then
        echo "$space_display"
    else
        echo "$1"
    fi
}

# Map a fzf --expect key name to the literal string fzf emits on that key.
fzf_key_name() {
    if [[ "$1" == "space" ]]; then
        echo "space"
    else
        echo "$1"
    fi
}

# --- Build menu --------------------------------------------------------------

sessions_display=$(display_key "$sessions_key")
windows_display=$(display_key "$windows_key")
config_display=$(display_key "$config_key")

menu=$(printf '%s\n' \
    "  ${sessions_display}  ${sessions_label}     ${sessions_desc}" \
    "  ${windows_display}  ${windows_label}      ${windows_desc}" \
    "  ${config_display}  ${config_label}       ${config_desc}")

# --- Strip conflicting FZF_DEFAULT_OPTS --------------------------------------

FZF_DEFAULT_OPTS=$(printf '%s' "$FZF_DEFAULT_OPTS" | sed 's/--height=[^ ]*//; s/--border[^ ]*//')
export FZF_DEFAULT_OPTS

# --- Build --expect list from configured keys --------------------------------

expect_list=$(fzf_key_name "$sessions_key")
expect_list="${expect_list},$(fzf_key_name "$windows_key")"
expect_list="${expect_list},$(fzf_key_name "$config_key")"

# --- Run fzf -----------------------------------------------------------------
# --print-query: line 1 = query, line 2 = key pressed, line 3 = selection

fzf_output=$(echo "$menu" | fzf \
    --print-query \
    --expect="$expect_list" \
    --reverse \
    --no-info \
    --no-preview \
    --prompt "$menu_prompt" \
    --header "$menu_header")

fzf_exit=$?

# Line 1 = query (unused at this level), line 2 = key, line 3 = selection.
key=$(echo "$fzf_output" | sed -n '2p')
selection=$(echo "$fzf_output" | sed -n '3p')

# Escape pressed — exit cleanly.
if [[ $fzf_exit -eq 130 ]]; then
    exit 0
fi

# --- Route to sub-palette ----------------------------------------------------

palette=""

# Hotkey takes priority.
if [[ "$key" == "$(fzf_key_name "$sessions_key")" ]]; then
    palette="sessions"
elif [[ "$key" == "$(fzf_key_name "$windows_key")" ]]; then
    palette="windows"
elif [[ "$key" == "$(fzf_key_name "$config_key")" ]]; then
    palette="config"
elif [[ -n "$selection" ]]; then
    # Enter pressed — match by label in the selection string.
    if [[ "$selection" == *"$sessions_label"* ]]; then
        palette="sessions"
    elif [[ "$selection" == *"$windows_label"* ]]; then
        palette="windows"
    elif [[ "$selection" == *"$config_label"* ]]; then
        palette="config"
    fi
fi

if [[ -n "$palette" ]]; then
    exec "${CURRENT_DIR}/palettes/${palette}.sh"
fi
