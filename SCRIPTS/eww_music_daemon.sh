#!/bin/bash

eww daemon >/dev/null 2>&1
sleep 1

last_state=""

while true; do
  current_state="$(playerctl status 2>/dev/null || echo "Stopped")"

  if [ "$current_state" = "Playing" ]; then
    if [ "$last_state" != "Playing" ]; then
      eww open musicbar >/dev/null 2>&1
    fi
  else
    if [ "$last_state" = "Playing" ]; then
      eww close musicbar >/dev/null 2>&1
    fi
  fi

  last_state="$current_state"
  sleep 1
done