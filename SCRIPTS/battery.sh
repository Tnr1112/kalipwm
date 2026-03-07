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

case "$status" in
	Charging)
		icon=""
		color="#22c55e"
		;;
	Full)
		icon=""
		color="#22d3ee"
		;;
	"Not charging")
		color="#22d3ee"
		;;
	Discharging)
		color="#ff3dbf"
		;;
	*)
		color="#a6b3c6"
		;;
esac

if [ "$capacity" -ge 90 ]; then
	icon=""
elif [ "$capacity" -ge 65 ]; then
	icon=""
elif [ "$capacity" -ge 45 ]; then
	icon=""
elif [ "$capacity" -ge 15 ]; then
	icon=""
else
	icon=""
fi

if [ "$status" = "Charging" ]; then
	icon=""
fi

echo -e "%{F${color}}${icon}%{F-} %{F#eaf2ff}${capacity}%"
