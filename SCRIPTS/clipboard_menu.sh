#!/bin/bash

export CM_LAUNCHER=rofi
export CM_LAUNCHER_ARGS="-dmenu -i -p Clipboard -theme $HOME/.config/polybar/scripts/themes/clipboard.rasi"

if clipmenu >/dev/null; then
    xdotool key --clearmodifiers Shift+Insert
fi
