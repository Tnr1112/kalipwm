#!/bin/bash

BATTERY_PATH=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n 1)
[ -z "$BATTERY_PATH" ] && exit 0

command -v acpi >/dev/null 2>&1 || exit 0

BAT_INFO=$(acpi -b | head -n 1)
[ -z "$BAT_INFO" ] && exit 0

STATE=$(echo "$BAT_INFO" | awk -F': ' '{print $2}' | awk -F', ' '{print $1}')
PERCENT=$(echo "$BAT_INFO" | awk -F', ' '{print $2}')

[ -z "$PERCENT" ] && PERCENT="$(cat "$BATTERY_PATH/capacity" 2>/dev/null)%"
[ -z "$PERCENT" ] && exit 0

if [ "$STATE" = "Discharging" ]; then
	echo -e "%{F#FF0000} %{F#e2ee6a}${PERCENT}%{u-}"
else
	echo -e "%{F#27FF00} %{F#e2ee6a}${PERCENT}%{u-}"
fi
