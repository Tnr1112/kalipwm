#!/usr/bin/env sh

COMMAND="$1"
VALUE="$2"
STEP=5

case "$COMMAND" in
  up)
    pamixer -i "${VALUE:-$STEP}"
    ;;
  down)
    pamixer -d "${VALUE:-$STEP}"
    ;;
  mute)
    pamixer -t
    ;;
  get)
    pamixer --get-volume
    ;;
  set)
    if [ -z "$VALUE" ]; then
      echo "Usage: $0 set <0-100>" >&2
      exit 1
    fi
    pamixer --set-volume "$VALUE"
    ;;
  *)
    echo "Usage: $0 <up|down|mute|get|set> [value]" >&2
    exit 1
    ;;
esac
