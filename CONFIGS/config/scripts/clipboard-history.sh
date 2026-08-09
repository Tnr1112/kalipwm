#!/usr/bin/env bash
set -euo pipefail

if ! command -v clipmenu >/dev/null 2>&1; then
    notify-send "clipmenu no está instalado" 2>/dev/null || true
    exit 1
fi

clipmenu -p "Clipboard" | xdotool type --clearmodifiers --file -
