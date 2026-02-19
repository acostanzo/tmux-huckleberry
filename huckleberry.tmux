#!/usr/bin/env bash
# TPM entry point — sources config, binds the popup key.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${CURRENT_DIR}/scripts/helpers.sh"
source "${CURRENT_DIR}/scripts/variables.sh"

bind_key=$(get_tmux_option "$HUCKLEBERRY_BIND" "$HUCKLEBERRY_BIND_DEFAULT")
width=$(get_tmux_option "$HUCKLEBERRY_WIDTH" "$HUCKLEBERRY_WIDTH_DEFAULT")
height=$(get_tmux_option "$HUCKLEBERRY_HEIGHT" "$HUCKLEBERRY_HEIGHT_DEFAULT")
pos_x=$(get_tmux_option "$HUCKLEBERRY_X" "$HUCKLEBERRY_X_DEFAULT")
pos_y=$(get_tmux_option "$HUCKLEBERRY_Y" "$HUCKLEBERRY_Y_DEFAULT")
title=$(get_tmux_option "$HUCKLEBERRY_TITLE" "$HUCKLEBERRY_TITLE_DEFAULT")

tmux bind-key "$bind_key" display-popup \
    -E \
    -b rounded \
    -w "$width" \
    -h "$height" \
    -x "$pos_x" \
    -y "$pos_y" \
    -T "$title" \
    "${CURRENT_DIR}/scripts/huckleberry.sh"
