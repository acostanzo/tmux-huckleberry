#!/usr/bin/env bash
# shellcheck disable=SC1091  # sourced files are resolved at runtime
# Config sub-palette — reload config and manage TPM plugins via fzf.
# Uses a while-true loop so Escape in sub-pickers returns to the action list.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=common.sh
source "${CURRENT_DIR}/common.sh"

strip_fzf_opts

get_tmux_option "$HUCKLEBERRY_CONFIG_PROMPT" "$HUCKLEBERRY_CONFIG_PROMPT_DEFAULT"; prompt="$REPLY"
get_tmux_option "$HUCKLEBERRY_CONFIG_HEADER" "$HUCKLEBERRY_CONFIG_HEADER_DEFAULT"; header="$REPLY"
get_tmux_option "$HUCKLEBERRY_CONFIG_FOOTER" "$HUCKLEBERRY_CONFIG_FOOTER_DEFAULT"; footer="$REPLY"
get_tmux_option "$HUCKLEBERRY_HEADER_BORDER" "$HUCKLEBERRY_HEADER_BORDER_DEFAULT"; header_border="$REPLY"
get_tmux_option "$HUCKLEBERRY_FOOTER_BORDER" "$HUCKLEBERRY_FOOTER_BORDER_DEFAULT"; footer_border="$REPLY"

header_border_args=(--header-border)
[[ -n "$header_border" ]] && header_border_args=(--header-border "$header_border")
footer_border_args=(--footer-border)
[[ -n "$footer_border" ]] && footer_border_args=(--footer-border "$footer_border")

get_tmux_option "$HUCKLEBERRY_CFG_RELOAD" "$HUCKLEBERRY_CFG_RELOAD_DEFAULT"; reload_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_CFG_TPM_INSTALL" "$HUCKLEBERRY_CFG_TPM_INSTALL_DEFAULT"; tpm_install_label="$REPLY"
get_tmux_option "$HUCKLEBERRY_CFG_TPM_UPDATE" "$HUCKLEBERRY_CFG_TPM_UPDATE_DEFAULT"; tpm_update_label="$REPLY"

# --- Detect config path (respect XDG_CONFIG_HOME) ----------------------------

xdg_config="${XDG_CONFIG_HOME:-$HOME/.config}"

config_path=""
if [[ -f "${xdg_config}/tmux/tmux.conf" ]]; then
    config_path="${xdg_config}/tmux/tmux.conf"
elif [[ -f "${HOME}/.tmux.conf" ]]; then
    config_path="${HOME}/.tmux.conf"
fi

# --- Detect TPM path ----------------------------------------------------------

tpm_path=""
if [[ -n "${TMUX_PLUGIN_MANAGER_PATH:-}" ]]; then
    tpm_path="${TMUX_PLUGIN_MANAGER_PATH%/}/tpm"
elif [[ -d "${xdg_config}/tmux/plugins/tpm" ]]; then
    tpm_path="${xdg_config}/tmux/plugins/tpm"
elif [[ -d "${HOME}/.tmux/plugins/tpm" ]]; then
    tpm_path="${HOME}/.tmux/plugins/tpm"
fi

# --- Build action list --------------------------------------------------------

actions="reload::${reload_label}"
if [[ -n "$tpm_path" ]]; then
    actions+=$'\n'"tpm-install::${tpm_install_label}"
    actions+=$'\n'"tpm-update::${tpm_update_label}"
fi

# --- Main loop — sub-pickers return here on Escape ----------------------------

while true; do
    selection=$(echo "$actions" | fzf \
        --reverse \
        --no-info \
        --no-separator \
        --no-preview \
        --header-first \
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

    action="${selection%%::*}"

    case "$action" in
        reload)
            if [[ -n "$config_path" ]]; then
                tmux source-file "$config_path" \; display-message "Config reloaded"
            else
                tmux display-message "No tmux config found"
            fi
            exit 0
            ;;
        tpm-install)
            tmux run-shell "${tpm_path}/bindings/install_plugins"
            exit 0
            ;;
        tpm-update)
            tmux run-shell "${tpm_path}/bindings/update_plugins"
            exit 0
            ;;
    esac
done
