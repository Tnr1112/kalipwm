#!/bin/bash

CFG_FILE="/tmp/kalipwm-eww-cava.conf"

cat > "$CFG_FILE" << 'EOF'
[general]
bars = 24
framerate = 30
sensitivity = 100

[input]
method = pulse

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
channels = mono
EOF

if ! command -v cava >/dev/null 2>&1; then
  while true; do
    printf '▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁\n'
    sleep 1
  done
fi

cava -p "$CFG_FILE" 2>/dev/null | while IFS=';' read -r -a values; do
  line=""
  for value in "${values[@]}"; do
    case "$value" in
      0) char="▁" ;;
      1) char="▂" ;;
      2) char="▃" ;;
      3) char="▄" ;;
      4) char="▅" ;;
      5) char="▆" ;;
      6) char="▇" ;;
      7) char="█" ;;
      *) char="▁" ;;
    esac
    line+="$char"
  done

  [ -z "$line" ] && line="▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁"
  printf '%s\n' "$line"
done