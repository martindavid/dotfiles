#!/bin/bash
# Restore full-width tiling after a screen-sharing session.
# Reverses the gap change made by share-on.sh.
# Safe to run at any time — idempotent if already in full-width mode.

set -uo pipefail

TOML="$(readlink "$HOME/.aerospace.toml")"
sed -i '' "s/= [0-9]*  # aerospace:share-gap/= 0  # aerospace:share-gap/g" "$TOML"
aerospace reload-config
echo "[share-off] Full-width tiling restored."
