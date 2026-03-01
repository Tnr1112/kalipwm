#!/usr/bin/env bash

WIDGET_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_COVER="$WIDGET_DIR/assets/DEFAULTImage.svg"
CACHE_DIR="$HOME/.cache/eww/music-widget"
mkdir -p "$CACHE_DIR"

show_default_cover() {
  echo "$DEFAULT_COVER"
  exit 0
}

COVER_URL="$(playerctl metadata mpris:artUrl 2>/dev/null)"
if [[ -z "$COVER_URL" ]]; then
  show_default_cover
fi

if [[ "$COVER_URL" == file://* ]]; then
  LOCAL_PATH="${COVER_URL#file://}"
  LOCAL_PATH="${LOCAL_PATH//%20/ }"
  if [[ -f "$LOCAL_PATH" ]]; then
    echo "$LOCAL_PATH"
    exit 0
  fi
  show_default_cover
fi

URL_HASH="$(echo -n "$COVER_URL" | md5sum | awk '{print $1}')"
EXTENSION="${COVER_URL##*.}"
if [[ "$EXTENSION" == "$COVER_URL" ]] || [[ ${#EXTENSION} -gt 5 ]]; then
  EXTENSION="jpg"
fi
CACHED_COVER="$CACHE_DIR/$URL_HASH.$EXTENSION"

if [[ ! -f "$CACHED_COVER" ]]; then
  curl -s -L --max-time 5 "$COVER_URL" -o "$CACHED_COVER"
  if [[ $? -ne 0 ]] || [[ ! -s "$CACHED_COVER" ]]; then
    rm -f "$CACHED_COVER"
    show_default_cover
  fi
fi

if file "$CACHED_COVER" | grep -qiE 'image|jpeg|png|jpg|gif|webp'; then
  echo "$CACHED_COVER"
else
  rm -f "$CACHED_COVER"
  show_default_cover
fi
