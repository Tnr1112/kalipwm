#!/bin/sh

target=$(cat ~/.config/scripts/target)

if [ "$target" ]; then
    echo "%{F#22d3ee}󰃾%{F-} %{F#eaf2ff}$target%{F-}"
else
    echo "%{F#ff3dbf}󰇇%{F-} %{F#a6b3c6}No target%{F-}"
fi
