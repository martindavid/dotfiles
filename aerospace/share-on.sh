#!/bin/bash
# Confine tiled windows to a centered 16:9 (3840×2160) band for screen sharing
# on the LG UltraFine 40U990A-W (5120px wide, 21:9).
#
# Gap math: (5120 - 3840) / 2 = 640 logical points at native scaling.
# Gap targets 16:10 (3456×2160) — optimised for MacBook Pro viewers.
# For 16:9 viewers use GAP=640 instead.
# If the display runs scaled (logical width ~2560), halve the gap: GAP=416.
#
# Safety: only modifies gaps when the ultrawide is actually connected.
# On MacBook Pro alone, this exits without touching the config.

set -uo pipefail

GAP=832

if ! aerospace list-monitors 2>/dev/null | grep -qi 'LG ULTRAFINE'; then
  echo "[share-on] Ultrawide not detected — no gap change applied." >&2
  exit 0
fi

TOML="$(readlink "$HOME/.aerospace.toml")"
sed -i '' "s/= 0  # aerospace:share-gap/= ${GAP}  # aerospace:share-gap/g" "$TOML"
aerospace reload-config
echo "[share-on] outer.left/right set to ${GAP}px — layout confined to 16:9 center."
