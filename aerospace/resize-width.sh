#!/bin/bash
# Set focused tiled window to a specific percentage of monitor width.
# Usage: resize-width.sh <percentage>
#
# Reads monitor width and current window width via osascript, calculates
# the delta, then applies it via `aerospace resize width`.

PERCENT="${1:-50}"

# Get monitor width (logical) and current window width from System Events
DIMS=$(osascript <<'EOF'
tell application "Finder"
  set {sx, sy, sw, sh} to bounds of window of desktop
end tell
tell application "System Events"
  tell (first process whose frontmost is true)
    set wsize to size of front window
    set ww to item 1 of wsize
  end tell
end tell
return (sw as text) & " " & (ww as text)
EOF
)

MONITOR_W=$(echo "$DIMS" | awk '{print $1}')
CURRENT_W=$(echo "$DIMS" | awk '{print $2}')
TARGET_W=$(echo "$MONITOR_W $PERCENT" | awk '{printf "%d", $1 * $2 / 100}')
DELTA=$((TARGET_W - CURRENT_W))

[[ $DELTA -eq 0 ]] && exit 0

if [[ $DELTA -gt 0 ]]; then
  aerospace resize width "+${DELTA}"
else
  aerospace resize width "${DELTA}"
fi
