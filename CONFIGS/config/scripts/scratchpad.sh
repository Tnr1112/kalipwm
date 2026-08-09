#!/usr/bin/env bash
set -euo pipefail

# Monitor-aware scratchpad modelled after gh0stzk/dotfiles' Bspwm-ScratchPad.
CLASS="scratchpad"
WIDTH_PERCENT=70
HEIGHT_PERCENT=35

window_id() {
    xdotool search --class "$CLASS" 2>/dev/null | head -n 1 || true
}

geometry() {
    local monitor
    monitor=$(bspc query -T -m focused)
    local width height x y
    width=$(jq -r '.rectangle.width' <<<"$monitor")
    height=$(jq -r '.rectangle.height' <<<"$monitor")
    x=$(jq -r '.rectangle.x' <<<"$monitor")
    y=$(jq -r '.rectangle.y' <<<"$monitor")
    SCRATCH_WIDTH=$((width * WIDTH_PERCENT / 100))
    SCRATCH_HEIGHT=$((height * HEIGHT_PERCENT / 100))
    SCRATCH_X=$((x + (width - SCRATCH_WIDTH) / 2))
    SCRATCH_Y=$y
}

geometry
id=$(window_id)

if [ -n "$id" ]; then
    hidden=$(bspc query -T -n "$id" | jq -r '.hidden')
    if [ "$hidden" = "true" ]; then
        bspc node "$id" -m focused -t floating -g sticky=on -g hidden=off -f
        xdotool windowmove "$id" "$SCRATCH_X" "$SCRATCH_Y"
        xdotool windowsize "$id" "$SCRATCH_WIDTH" "$SCRATCH_HEIGHT"
    else
        bspc node "$id" -g hidden=on
    fi
    exit 0
fi

bspc rule -a "$CLASS" state=floating sticky=on layer=above \
    rectangle="${SCRATCH_WIDTH}x${SCRATCH_HEIGHT}+${SCRATCH_X}+${SCRATCH_Y}" --one-shot
kitty --class "$CLASS" --title "Scratchpad" &

for _ in $(seq 1 20); do
    id=$(window_id)
    if [ -n "$id" ]; then
        bspc node "$id" -t floating -g sticky=on -f
        xdotool windowmove "$id" "$SCRATCH_X" "$SCRATCH_Y"
        xdotool windowsize "$id" "$SCRATCH_WIDTH" "$SCRATCH_HEIGHT"
        exit 0
    fi
    sleep 0.1
done

notify-send "Scratchpad" "Kitty no creó la ventana scratchpad" 2>/dev/null || true
