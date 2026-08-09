#!/usr/bin/env bash
set -euo pipefail

class="scratchpad"
if xdotool search --class "$class" | grep -q .; then
    xdotool search --class "$class" | head -n1 | xargs -r -I{} bspc node {} -f
else
    kitty --class "$class" --title "Scratchpad" "$SHELL" -ic 'clear; exec $SHELL' &
fi
