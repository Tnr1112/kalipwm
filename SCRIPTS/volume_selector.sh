#!/bin/bash

current="$(pamixer --get-volume 2>/dev/null || echo 0)"

options="0\n10\n20\n30\n40\n50\n60\n70\n80\n90\n100\n110\n120\n130\n140\n150\n+5\n-5\nmute\nunmute"

choice="$(printf "%b" "$options" | rofi -dmenu -i -p "Volumen (${current}%)" -theme "$HOME/.config/polybar/scripts/themes/launcher.rasi")"

[ -z "$choice" ] && exit 0

case "$choice" in
    "+5")
        pamixer -i 5
        ;;
    "-5")
        pamixer -d 5
        ;;
    "mute")
        pamixer -m
        ;;
    "unmute")
        pamixer -u
        ;;
    *)
        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            pamixer --set-volume "$choice"
        fi
        ;;
esac
