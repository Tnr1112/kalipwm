#!/bin/bash

command -v acpi >/dev/null 2>&1 || exit 0

BAT_INFO=$(acpi -b | head -n 1)
[ -z "$BAT_INFO" ] && exit 0

STATE=$(echo "$BAT_INFO" | awk -F': ' '{print $2}' | awk -F', ' '{print $1}')
PERCENT=$(echo "$BAT_INFO" | awk -F', ' '{print $2}')

[ -z "$PERCENT" ] && BATTERY_PATH=$(for device in /sys/class/power_supply/*; do [ -f "$device/type" ] && grep -q '^Battery$' "$device/type" && echo "$device" && break; done)
[ -z "$PERCENT" ] && PERCENT="$(cat "$BATTERY_PATH/capacity" 2>/dev/null)%"
[ -z "$PERCENT" ] && exit 0

PERCENT_VALUE=$(echo "$PERCENT" | tr -cd '0-9')
[ -n "$PERCENT_VALUE" ] && PERCENT="${PERCENT_VALUE}%"

if [ "$PERCENT_VALUE" -ge 90 ]; then
	ICON=$''
elif [ "$PERCENT_VALUE" -ge 65 ]; then
	ICON=$''
elif [ "$PERCENT_VALUE" -ge 40 ]; then
	ICON=$''
elif [ "$PERCENT_VALUE" -ge 15 ]; then
	ICON=$''
else
	ICON=$''
fi
BOLT=$''

if [ "$STATE" = "Discharging" ]; then
	echo -e "%{F#FF6B6B}%{T9}${ICON}%{T-} %{F#e2ee6a}${PERCENT}%{u-}"
else
	echo -e "%{F#6BFF95}%{T10}${BOLT}%{T-} %{T9}${ICON}%{T-} %{F#e2ee6a}${PERCENT}%{u-}"
fi
