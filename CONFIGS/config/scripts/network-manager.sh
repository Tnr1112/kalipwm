#!/usr/bin/env bash
set -euo pipefail

THEME="${ROFI_THEME:-$HOME/.config/rofi/themes/network-manager.rasi}"

if ! command -v nmcli >/dev/null 2>&1; then
    notify-send "nmcli is unavailable" 2>/dev/null || true
    exit 1
fi

wifi_state=$(nmcli radio wifi | awk 'NR==2 {print $1}')
active_connections=$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | tr '\n' ' ' | sed 's/[[:space:]]*$//')
[ -n "$active_connections" ] || active_connections="none"

choice=$(printf '%s\n' "Toggle Wi-Fi" "Connect to Wi-Fi" "Toggle Ethernet" "Disconnect Active" "Close" | rofi -dmenu -i -theme "$THEME" -p "Network" -mesg "Wi-Fi: ${wifi_state:-off} • Active: ${active_connections}")

case "$choice" in
    "Toggle Wi-Fi")
        if nmcli radio wifi | grep -q 'enabled'; then
            nmcli radio wifi off >/dev/null 2>&1 || true
            notify-send "Wi-Fi disabled" 2>/dev/null || true
        else
            nmcli radio wifi on >/dev/null 2>&1 || true
            notify-send "Wi-Fi enabled" 2>/dev/null || true
        fi
        ;;
    "Connect to Wi-Fi")
        ssid=$(nmcli -t -f signal,ssid dev wifi list 2>/dev/null | awk -F: 'NF {print $2}' | sort -u | rofi -dmenu -i -theme "$THEME" -p "Wi-Fi SSID")
        if [ -n "$ssid" ]; then
            if nmcli device wifi connect "$ssid" >/dev/null 2>&1; then
                notify-send "Connected to $ssid" 2>/dev/null || true
            else
                notify-send "Could not connect to $ssid" 2>/dev/null || true
            fi
        fi
        ;;
    "Toggle Ethernet")
        ethernet_name=$(nmcli -t -f name,type connection show --active 2>/dev/null | awk -F: '$2=="802-3-ethernet" {print $1; exit}')
        if [ -n "$ethernet_name" ]; then
            nmcli connection down "$ethernet_name" >/dev/null 2>&1 || true
            notify-send "Ethernet disconnected" 2>/dev/null || true
        else
            ethernet_name=$(nmcli -t -f name,type connection show 2>/dev/null | awk -F: '$2=="802-3-ethernet" {print $1; exit}')
            if [ -n "$ethernet_name" ]; then
                nmcli connection up "$ethernet_name" >/dev/null 2>&1 || true
                notify-send "Ethernet connected" 2>/dev/null || true
            fi
        fi
        ;;
    "Disconnect Active")
        while IFS= read -r conn; do
            [ -n "$conn" ] && nmcli connection down "$conn" >/dev/null 2>&1 || true
        done < <(nmcli -t -f name connection show --active 2>/dev/null)
        notify-send "Active connections disconnected" 2>/dev/null || true
        ;;
    *)
        exit 0
        ;;
esac
