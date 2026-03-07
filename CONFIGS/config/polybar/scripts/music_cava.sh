#!/bin/bash

CAVA_CONFIG="$HOME/.config/eww/cava.conf"

gradient_colors=(
    "#22d3ee"
    "#41bdef"
    "#61a6f0"
    "#8090f1"
    "#a079f2"
    "#bf63f3"
    "#df4cf4"
    "#ff3dbf"
)

bars_map=(" " "▂" "▃" "▄" "▅" "▆" "▇" "█")

render_from_values() {
    local rendered=""
    local idx=0

    for value in "$@"; do
        value="${value//[^0-9]/}"
        [ -z "$value" ] && value=0
        [ "$value" -gt 7 ] && value=7

        rendered+="%{F${gradient_colors[$value]}}${bars_map[$value]}%{F-}"

        ((idx++))
        [ "$idx" -ge 16 ] && break
    done

    echo "$rendered"
}

if command -v cava >/dev/null 2>&1 && [ -f "$CAVA_CONFIG" ]; then
    cava -p "$CAVA_CONFIG" 2>/dev/null | while IFS=';' read -r -a values; do
        echo "$(render_from_values "${values[@]}")"
    done
else
    while true; do
        echo "%{F#22d3ee}▁▂▃▄▅▆▇█%{F-}"
        sleep 1
    done
fi
