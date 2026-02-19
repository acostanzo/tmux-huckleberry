#!/usr/bin/env bash
# Shared infrastructure sourced by all sub-palettes.
# shellcheck disable=SC2034  # variables are used by sourcing scripts

PALETTES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$(cd "${PALETTES_DIR}/.." && pwd)"

# shellcheck source=../helpers.sh
source "${SCRIPTS_DIR}/helpers.sh"
# shellcheck source=../variables.sh
source "${SCRIPTS_DIR}/variables.sh"

# Strip layout options from FZF_DEFAULT_OPTS that conflict with the popup:
#   --height: forces inline mode, leaving a gap at the bottom
#   --border: redundant with the tmux popup border
strip_fzf_opts() {
    FZF_DEFAULT_OPTS=$(printf '%s' "$FZF_DEFAULT_OPTS" | sed 's/--height=[^ ]*//; s/--border[^ ]*//')
    export FZF_DEFAULT_OPTS
}
