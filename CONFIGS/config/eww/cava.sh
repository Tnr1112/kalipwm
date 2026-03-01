#!/bin/bash

CONFIG_FILE="$HOME/.config/eww/cava.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    exit 0
fi

symbols=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

cava -p "$CONFIG_FILE" 2>/dev/null | while IFS=';' read -r -a values; do
    line=""

    for value in "${values[@]}"; do
        value="${value//[^0-9]/}"
        [ -z "$value" ] && value=0
        [ "$value" -gt 7 ] && value=7
        line+="${symbols[$value]}"
    done

    echo "$line"
done
