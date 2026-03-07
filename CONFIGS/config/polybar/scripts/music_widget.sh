#!/bin/bash

CAVA_CONFIG="$HOME/.config/eww/cava.conf"
NEON_CYAN="#22d3ee"
NEON_PINK="#ff3dbf"
NEON_PURPLE="#b026ff"
MARQUEE_WIDTH=26

# Paleta de 8 colores para el gradiente (de Cyan a Pink)
gradient_colors=(
    "#22d3ee" # Nivel 0 - Cyan
    "#41bdef" # Nivel 1
    "#61a6f0" # Nivel 2
    "#8090f1" # Nivel 3
    "#a079f2" # Nivel 4
    "#bf63f3" # Nivel 5
    "#df4cf4" # Nivel 6
    "#ff3dbf" # Nivel 7 - Pink
)

bars_map=(" " "▂" "▃" "▄" "▅" "▆" "▇" "█")

update_player() {
    status="$(playerctl status 2>/dev/null || echo "Stopped")"
    title="$(playerctl metadata title 2>/dev/null)"
    artist="$(playerctl metadata artist 2>/dev/null)"

    if [ -n "$title" ] && [ -n "$artist" ]; then
        track="$artist - $title"
    elif [ -n "$title" ]; then
        track="$title"
    else
        track=""
    fi

    if [ -n "$track" ]; then
        track="$track   •   "
    fi
}

render_from_values() {
    local rendered=""
    local idx=0

    for value in "$@"; do
        # Limpiamos el valor para evitar errores
        value="${value//[^0-9]/}"
        [ -z "$value" ] && value=0
        [ "$value" -gt 7 ] && value=7

        # Seleccionamos el color y el bloque exacto según la altura (0 a 7)
        local bar_color="${gradient_colors[$value]}"
        local bar_char="${bars_map[$value]}"

        # Aplicamos la sintaxis de color de Polybar a CADA barra
        rendered+="%{F${bar_color}}${bar_char}%{F-}"

        ((idx++))
        [ "$idx" -ge 16 ] && break
    done

    echo "$rendered"
}

emit_line() {
    local cava_line="$1"
    local display_track=""

    if [ -n "$track" ]; then
        local doubled_track="${track}${track}"
        local track_len=${#track}

        if [ "$track_len" -gt 0 ]; then
            local start=$((scroll_pos % track_len))
            display_track="${doubled_track:$start:$MARQUEE_WIDTH}"
        fi
    fi

    case "$status" in
        Playing)
            # cava_line ya trae sus propios colores, así que lo imprimimos directo
            echo "${cava_line}  %{F${NEON_PINK}}  ${display_track}%{F-}"
            ;;
        Paused)
            echo "%{F${NEON_PURPLE}}  Pausado %{F-} %{F${NEON_PINK}}${display_track}%{F-}"
            ;;
        *)
            echo "%{F${NEON_CYAN}}  Esperando señal...%{F-}"
            ;;
    esac
}

frame=0
scroll_pos=0
update_player

if command -v cava >/dev/null 2>&1 && [ -f "$CAVA_CONFIG" ]; then
    cava -p "$CAVA_CONFIG" 2>/dev/null | while IFS=';' read -r -a values; do
        ((frame++))

        if [ $((frame % 6)) -eq 0 ]; then
            ((scroll_pos++))
        fi

        if [ $((frame % 8)) -eq 0 ]; then
            update_player
        fi

        cava_line="$(render_from_values "${values[@]}")"
        emit_line "$cava_line"
    done
else
    while true; do
        update_player
        emit_line ""
        sleep 1
    done
fi