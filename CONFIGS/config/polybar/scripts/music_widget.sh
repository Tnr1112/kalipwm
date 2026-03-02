#!/bin/bash

CAVA_CONFIG="$HOME/.config/eww/cava.conf"
NEON_CYAN="#22d3ee"

bars_map=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

update_player() {
    status="$(playerctl status 2>/dev/null || echo "Stopped")"
}

render_from_values() {
    local rendered=""
    local idx=0

    for value in "$@"; do
        value="${value//[^0-9]/}"
        [ -z "$value" ] && value=0
        [ "$value" -gt 7 ] && value=7
        rendered+="${bars_map[$value]}"
        ((idx++))
        [ "$idx" -ge 16 ] && break
    done

    echo "$rendered"
}

emit_line() {
    local cava_line="$1"

    case "$status" in
        Playing)
            echo "%{F${NEON_CYAN}}${cava_line}%{F-}"
            ;;
        *)
            echo ""
            ;;
    esac
}

frame=0
update_player

if command -v cava >/dev/null 2>&1 && [ -f "$CAVA_CONFIG" ]; then
    cava -p "$CAVA_CONFIG" 2>/dev/null | while IFS=';' read -r -a values; do
        ((frame++))
        if [ $((frame % 8)) -eq 0 ]; then
            update_player
        fi

        cava_line="$(render_from_values "${values[@]}")"
        emit_line "$cava_line"
    done
else
    while true; do
        update_player
        emit_line ""
        sleep 1
    done
fi
