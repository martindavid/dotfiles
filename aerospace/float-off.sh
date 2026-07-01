#!/bin/bash
# Return all windows in the current workspace to tiling.
# Uses --window-id so no focus changes occur.

set -uo pipefail

aerospace list-windows --workspace focused --format '%{window-id}' | \
  while read -r id; do
    [[ -z "$id" ]] && continue
    aerospace layout --window-id "$id" tiling
  done
