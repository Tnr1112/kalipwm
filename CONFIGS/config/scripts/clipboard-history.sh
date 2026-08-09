#!/usr/bin/env bash
set -euo pipefail

THEME="${ROFI_THEME:-$HOME/.config/rofi/themes/clipboard.rasi}"

if command -v clipmenu >/dev/null 2>&1 && command -v xdotool >/dev/null 2>&1; then
    # clipmenu copies the selected history entry to the PRIMARY selection. Once
    # Rofi closes, focus returns to the previous window and Shift+Insert pastes it.
    CM_LAUNCHER="rofi -dmenu -i -theme \"$THEME\" -p Clipboard -mesg \"Selecciona una entrada para pegar\"" clipmenu >/dev/null 2>&1 || exit 0
    xdotool key --clearmodifiers Shift+Insert
    exit 0
fi

if ! command -v xclip >/dev/null 2>&1; then
    notify-send "Clipboard tools are unavailable" 2>/dev/null || true
    exit 1
fi

value=$(xclip -selection clipboard -o 2>/dev/null || true)
if [ -z "$value" ]; then
    notify-send "Clipboard is empty" 2>/dev/null || true
    exit 0
fi

choice=$(printf '%s\n' "Paste clipboard" "Clear clipboard" | rofi -dmenu -i -theme "$THEME" -p "Clipboard" -mesg "Current clipboard content")
case "$choice" in
    "Paste clipboard")
        if command -v xdotool >/dev/null 2>&1; then
            printf '%s' "$value" | xdotool type --clearmodifiers --file -
        fi
        ;;
    "Clear clipboard")
        printf '' | xclip -selection clipboard
        notify-send "Clipboard cleared" 2>/dev/null || true
        ;;
    *)
        exit 0
        ;;
esac
