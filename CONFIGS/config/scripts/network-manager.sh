#!/usr/bin/env bash
set -euo pipefail

if ! command -v nmcli >/dev/null 2>&1; then
    echo "nmcli no está disponible" >&2
    exit 1
fi

wifi_status=$(nmcli radio wifi | awk 'NR==2 {print $1}')
active_connections=$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | tr '\n' ' ')

main_choice=$(printf 'Wi-Fi Toggle\nConnect to Wi-Fi\nEthernet Toggle\nDisconnect Active\n' | rofi -dmenu -i -p 'Network' -mesg "Wi-Fi: ${wifi_status:-off} | Active: ${active_connections:-none}")

case "$main_choice" in
    "Wi-Fi Toggle")
        if nmcli radio wifi | grep -q 'enabled'; then
            nmcli radio wifi off
        else
            nmcli radio wifi on
        fi
        ;;
    "Connect to Wi-Fi")
        ssid=$(nmcli -t -f signal,ssid dev wifi list 2>/dev/null | awk -F: 'NF{print $2}' | sort -u | rofi -dmenu -i -p 'Wi-Fi SSID')
        if [ -n "$ssid" ]; then
            nmcli device wifi connect "$ssid" 2>/dev/null || true
        fi
        ;;
    "Ethernet Toggle")
        if nmcli connection show --active | grep -q 'ethernet'; then
            nmcli connection down "$(nmcli -t -f name,type connection show --active | awk -F: '$2=="802-3-ethernet"{print $1; exit}')" 2>/dev/null || true
        else
            nmcli connection up "$(nmcli -t -f name,type connection show | awk -F: '$2=="802-3-ethernet"{print $1; exit}')" 2>/dev/null || true
        fi
        ;;
    "Disconnect Active")
        active_name=$(nmcli -t -f name connection show --active 2>/dev/null | head -n1)
        if [ -n "$active_name" ]; then
            nmcli connection down "$active_name" 2>/dev/null || true
        fi
        ;;
    *)
        exit 0
        ;;
esac
