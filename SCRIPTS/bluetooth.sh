#!/bin/bash

if ! command -v bluetoothctl >/dev/null 2>&1; then
    echo "%{F#A6B3C6}󰂲%{F-}"
    exit 0
fi

status="$(bluetoothctl show 2>/dev/null)"
if echo "$status" | grep -q "Powered: yes"; then
    if echo "$status" | grep -q "Discoverable: yes"; then
        echo "%{F#22D3EE}󰂯%{F-}"
    else
        echo "%{F#22D3EE}󰂯%{F-}"
    fi
else
    echo "%{F#A6B3C6}󰂲%{F-}"
fi
