#!/bin/sh

# Copy Target IP
target=$(cat ~/.config/scripts/target)
searchString="- "
#echo -n "$target" | xclip -sel clipboard
echo -n ${target#*$searchString} | xclip -sel clipboard
