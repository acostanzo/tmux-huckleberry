#!/usr/bin/env bash
# Top-level dispatcher — runs inside the tmux popup.
# Routes to sub-palettes under scripts/palettes/.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

exec "${CURRENT_DIR}/palettes/sessions.sh"
