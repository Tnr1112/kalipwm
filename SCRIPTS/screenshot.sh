#!/usr/bin/env bash
set -euo pipefail

THEME="${ROFI_THEME:-$HOME/.config/rofi/themes/shared.rasi}"
OUT_DIR="$HOME/Pictures/screenshots"
mkdir -p "$OUT_DIR"

capture_full() {
    local path="$OUT_DIR/$(date '+%Y-%m-%d-%H-%M-%S').png"
    scrot -q 100 "$path"
    printf '%s\n' "$path"
}

capture_select() {
    local path="$OUT_DIR/$(date '+%Y-%m-%d-%H-%M-%S').png"
    scrot -s -q 100 -l mode=classic "$path"
    printf '%s\n' "$path"
}

capture_window() {
    local path="$OUT_DIR/$(date '+%Y-%m-%d-%H-%M-%S').png"
    scrot -q 100 --focused -b "$path"
    printf '%s\n' "$path"
}

choice=$(printf '%s\n' "Full screen" "Selection" "Active window" "Cancel" | rofi -dmenu -i -theme "$THEME" -p "Screenshot" -mesg "Capture and save a screenshot")

case "$choice" in
    "Full screen")
        path=$(capture_full)
        ;;
    "Selection")
        path=$(capture_select)
        ;;
    "Active window")
        path=$(capture_window)
        ;;
    *)
        exit 0
        ;;
esac

if command -v xclip >/dev/null 2>&1; then
    xclip -selection clipboard -t image/png "$path" >/dev/null 2>&1 || true
fi

notify-send "Screenshot saved" "$path" 2>/dev/null || true
