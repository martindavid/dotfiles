#!/bin/bash
# Float all windows in the current workspace.
# Uses --window-id so no focus changes occur — windows stay where they are.

set -uo pipefail

aerospace list-windows --workspace focused --format '%{window-id}' | \
  while read -r id; do
    [[ -z "$id" ]] && continue
    aerospace layout --window-id "$id" floating
  done
