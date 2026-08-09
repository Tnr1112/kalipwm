#!/usr/bin/env bash
set -euo pipefail

class="scratchpad"

if xdotool search --class "$class" 2>/dev/null | grep -q .; then
    node_id=$(xdotool search --class "$class" 2>/dev/null | head -n1)
    [ -n "$node_id" ] && bspc node "$node_id" -f
    [ -n "$node_id" ] && bspc node "$node_id" -t floating
    [ -n "$node_id" ] && bspc node "$node_id" -g sticky=on
    exit 0
fi

kitty --class "$class" --title "Scratchpad" "$SHELL" -ic 'clear; exec $SHELL' &
pid=$!
for _ in $(seq 1 10); do
    node_id=$(xdotool search --sync --class "$class" 2>/dev/null | head -n1 || true)
    if [ -n "$node_id" ]; then
        bspc node "$node_id" -t floating >/dev/null 2>&1 || true
        bspc node "$node_id" -g sticky=on >/dev/null 2>&1 || true
        bspc node "$node_id" -f >/dev/null 2>&1 || true
        break
    fi
    sleep 0.1
    if ! kill -0 "$pid" 2>/dev/null; then
        break
    fi
done
