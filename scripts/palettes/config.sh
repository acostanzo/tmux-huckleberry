#!/usr/bin/env bash
# shellcheck disable=SC1091  # sourced files are resolved at runtime
# Config sub-palette — reload config and manage TPM plugins via fzf.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=common.sh
source "${CURRENT_DIR}/common.sh"

strip_fzf_opts

prompt=$(get_tmux_option "$HUCKLEBERRY_CONFIG_PROMPT" "$HUCKLEBERRY_CONFIG_PROMPT_DEFAULT")
header=$(get_tmux_option "$HUCKLEBERRY_CONFIG_HEADER" "$HUCKLEBERRY_CONFIG_HEADER_DEFAULT")

reload_label=$(get_tmux_option "$HUCKLEBERRY_CFG_RELOAD" "$HUCKLEBERRY_CFG_RELOAD_DEFAULT")
tpm_install_label=$(get_tmux_option "$HUCKLEBERRY_CFG_TPM_INSTALL" "$HUCKLEBERRY_CFG_TPM_INSTALL_DEFAULT")
tpm_update_label=$(get_tmux_option "$HUCKLEBERRY_CFG_TPM_UPDATE" "$HUCKLEBERRY_CFG_TPM_UPDATE_DEFAULT")

# --- Detect config path ------------------------------------------------------

config_path=""
if [[ -f "${HOME}/.config/tmux/tmux.conf" ]]; then
    config_path="${HOME}/.config/tmux/tmux.conf"
elif [[ -f "${HOME}/.tmux.conf" ]]; then
    config_path="${HOME}/.tmux.conf"
fi

# --- Detect TPM path ----------------------------------------------------------

tpm_path=""
if [[ -n "${TMUX_PLUGIN_MANAGER_PATH:-}" ]]; then
    tpm_path="${TMUX_PLUGIN_MANAGER_PATH%/}/tpm"
elif [[ -d "${HOME}/.config/tmux/plugins/tpm" ]]; then
    tpm_path="${HOME}/.config/tmux/plugins/tpm"
elif [[ -d "${HOME}/.tmux/plugins/tpm" ]]; then
    tpm_path="${HOME}/.tmux/plugins/tpm"
fi

# --- Build action list --------------------------------------------------------

actions="reload::${reload_label}"
if [[ -n "$tpm_path" ]]; then
    actions=$(printf '%s\n' \
        "$actions" \
        "tpm-install::${tpm_install_label}" \
        "tpm-update::${tpm_update_label}")
fi

selection=$(echo "$actions" | fzf \
    --reverse \
    --no-info \
    --no-preview \
    --delimiter '::' \
    --with-nth 2 \
    --prompt "$prompt" \
    --header "$header")

fzf_exit=$?

if [[ $fzf_exit -ne 0 ]]; then
    exit 0
fi

action="${selection%%::*}"

case "$action" in
    reload)
        if [[ -n "$config_path" ]]; then
            tmux source-file "$config_path" \; display-message "Config reloaded"
        else
            tmux display-message "No tmux config found"
        fi
        ;;
    tpm-install)
        tmux run-shell "${tpm_path}/bindings/install_plugins"
        ;;
    tpm-update)
        tmux run-shell "${tpm_path}/bindings/update_plugins"
        ;;
esac
