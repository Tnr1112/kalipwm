#!/bin/bash

NEON_CYAN="#22d3ee"
NEON_PINK="#ff3dbf"
NEON_PURPLE="#b026ff"
MARQUEE_WIDTH=30

scroll_pos=0

while true; do
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
        doubled_track="${track}${track}"
        track_len=${#track}
        start=$((scroll_pos % track_len))
        display_track="${doubled_track:$start:$MARQUEE_WIDTH}"
    else
        display_track=""
    fi

    case "$status" in
        Playing)
            echo "%{F${NEON_PINK}} ${display_track}%{F-}"
            ;;
        Paused)
            echo "%{F${NEON_PURPLE}} Pausado%{F-} %{F${NEON_PINK}}${display_track}%{F-}"
            ;;
        *)
            echo "%{F${NEON_CYAN}} Esperando señal...%{F-}"
            ;;
    esac

    ((scroll_pos++))
    sleep 0.4
done
