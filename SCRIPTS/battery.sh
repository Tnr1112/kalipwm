#!/bin/bash

BAT_PATH=""

if [ -d "/sys/class/power_supply/BAT0" ]; then
	BAT_PATH="/sys/class/power_supply/BAT0"
else
	for candidate in /sys/class/power_supply/BAT*; do
		if [ -d "$candidate" ]; then
			BAT_PATH="$candidate"
			break
		fi
	done
fi

if [ -z "$BAT_PATH" ] || [ ! -d "$BAT_PATH" ]; then
	exit 0
fi

capacity="$(cat "$BAT_PATH/capacity" 2>/dev/null)"
status="$(cat "$BAT_PATH/status" 2>/dev/null)"

if [ -z "$capacity" ] || [ -z "$status" ]; then
	exit 0
fi

level=$((capacity / 13))

if [ "$level" -lt 0 ]; then level=0; fi
if [ "$level" -gt 7 ]; then level=7; fi

bars=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")
progress="${bars[$level]}"

case "$status" in
	Charging)
		icon=""
		color="#22c55e"
		state="+"
		;;
	Full)
		icon=""
		color="#22d3ee"
		state="="
		;;
	Discharging)
		icon=""
		color="#ff3dbf"
		state="-"
		;;
	*)
		icon=""
		color="#a6b3c6"
		state="?"
		;;
esac

echo -e "%{F${color}}${icon}%{F-}%{F#a6b3c6}${state}%{F-}%{F#22d3ee}${progress}%{F-}%{F#eaf2ff}${capacity}%"
