#!/usr/bin/env bash
# TPM entry point — sources config, binds the popup key.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Dependency checks -------------------------------------------------------

if ! command -v fzf &>/dev/null; then
    tmux display-message "huckleberry: fzf not found — install fzf to use this plugin"
    # shellcheck disable=SC2317
    return 2>/dev/null || exit 1
fi

source "${CURRENT_DIR}/scripts/helpers.sh"
source "${CURRENT_DIR}/scripts/variables.sh"

get_tmux_option "$HUCKLEBERRY_BIND" "$HUCKLEBERRY_BIND_DEFAULT"; bind_key="$REPLY"
get_tmux_option "$HUCKLEBERRY_WIDTH" "$HUCKLEBERRY_WIDTH_DEFAULT"; width="$REPLY"
get_tmux_option "$HUCKLEBERRY_HEIGHT" "$HUCKLEBERRY_HEIGHT_DEFAULT"; height="$REPLY"
get_tmux_option "$HUCKLEBERRY_X" "$HUCKLEBERRY_X_DEFAULT"; pos_x="$REPLY"
get_tmux_option "$HUCKLEBERRY_Y" "$HUCKLEBERRY_Y_DEFAULT"; pos_y="$REPLY"
get_tmux_option "$HUCKLEBERRY_TITLE" "$HUCKLEBERRY_TITLE_DEFAULT"; title="$REPLY"
get_tmux_option "$HUCKLEBERRY_BORDER_LINES" "$HUCKLEBERRY_BORDER_LINES_DEFAULT"; border_lines="$REPLY"

tmux bind-key "$bind_key" display-popup \
    -E \
    -b "$border_lines" \
    -w "$width" \
    -h "$height" \
    -x "$pos_x" \
    -y "$pos_y" \
    -T "$title" \
    "${CURRENT_DIR}/scripts/huckleberry.sh"
