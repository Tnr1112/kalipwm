#! /bin/sh

screens_dir="$HOME/screenshots"
mkdir -p "$screens_dir"
output="$screens_dir/%Y-%m-%d-%T-sc.png"

case "$1" in
	"select") scrot -s -q 100 -l mode=classic "$output" || exit ;;
	"window") scrot -q 100 --focused -b "$output" || exit ;;
	*) scrot "$output" || exit ;;
esac

notify-send "Screenshot guardada" "$screens_dir"
