#!/usr/bin/env bash
# Shared infrastructure sourced by all sub-palettes.
# shellcheck disable=SC1091,SC2034  # sourced files resolved at runtime; vars used by sourcing scripts

PALETTES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$(cd "${PALETTES_DIR}/.." && pwd)"

# Guard: skip re-sourcing when the dispatcher already loaded these.
if [[ -z "${_huck_helpers_loaded:-}" ]]; then
    # shellcheck source=../helpers.sh
    source "${SCRIPTS_DIR}/helpers.sh"
    # shellcheck source=../variables.sh
    source "${SCRIPTS_DIR}/variables.sh"
fi
