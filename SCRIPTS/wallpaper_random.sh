#!/bin/bash
WALLPAPER=$(find ~/Wallpapers -type f | shuf -n 1)
feh --bg-fill "$WALLPAPER"
