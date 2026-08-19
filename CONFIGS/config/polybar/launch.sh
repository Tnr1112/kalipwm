#!/usr/bin/env sh

## Add this to your wm startup file.

# Terminate already running bar instances
killall -q polybar

## Wait until the processes have been shut down
while pgrep -u "$(id -u)" -x polybar >/dev/null; do sleep 1; done

## Launch
## One full pass of bars per connected monitor, so polybar is visible
## regardless of which screen you're using (see monitor_setup.sh).
for m in $(polybar -m | cut -d ':' -f 1); do
	export MONITOR=$m

	## Left bar
	polybar log -c ~/.config/polybar/current.ini &
	polybar secondary -c ~/.config/polybar/current.ini &
	polybar terciary -c ~/.config/polybar/current.ini &
	polybar quaternary -c ~/.config/polybar/current.ini &
	polybar quinto -c ~/.config/polybar/current.ini &

	## Right bar
	#polybar top -c ~/.config/polybar/current.ini &
	polybar primary -c ~/.config/polybar/current.ini &
	#polybar battery -c ~/.config/polybar/current.ini &
	#polybar bluetooth -c ~/.config/polybar/current.ini &

	## Center bar
	polybar primary -c ~/.config/polybar/workspace.ini &
done
unset MONITOR
