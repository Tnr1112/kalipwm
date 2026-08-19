#!/usr/bin/env bash
# Dual-monitor setup for bspwm + polybar.
# Bound to super+shift+m (sxhkdrc). Detects the external monitor,
# asks where to place it via rofi, applies xrandr with the monitor's
# own preferred mode (--auto), re-splits bspwm desktops 5/5 and
# restarts polybar.

set -euo pipefail

# Safety net for bugs not yet caught: if the script dies unexpectedly
# under `set -e`, this fires instead of failing completely silently —
# critical during a competition, where "nothing happened and I don't
# know why" is worse than a visible error.
trap 'notify-send -u critical "monitor_setup falló" "línea $LINENO — revisar el script" 2>/dev/null || true' ERR

PRIMARY="eDP"
WALLPAPER="$HOME/Wallpapers/wallpapersden.com_huawei-4k-stock-abstract_2560x1440.jpg"

connected=$(xrandr --query | awk '/ connected/{print $1}')
# grep -v exits 1 (no matches) when PRIMARY is the only connected output,
# which is exactly the "just unplugged everything" case this script must
# handle — don't let `set -e`/pipefail kill the script over that.
secondary=$(printf '%s\n' "$connected" | grep -v "^${PRIMARY}$" | head -n1 || true)

# ── orphan-window safety net ───────────────────────────────────────
# `bspc monitor -d NAMES...` destroys/recreates desktop objects. If a
# window happens to sit on a desktop at the exact moment it gets
# rewritten, bspwm can silently drop it from its managed tree while
# the X window stays mapped and fully alive — leaving it inert to any
# bspc command (can't move/resize/focus it). Snapshot what's managed
# before reconfiguring, and after, force-readopt (via an unmap/remap
# cycle, which produces a fresh MapRequest bspwm will catch) anything
# that fell out but is still a live X window.
managed_windows() {
    for m in $(bspc query -M --names 2>/dev/null); do
        for d in $(bspc query -D -m "$m" --names 2>/dev/null); do
            bspc query -N -d "$d" 2>/dev/null
        done
    done
    return 0
}

reclaim_lost_windows() {
    local before="$1" after
    after=$(managed_windows)
    for w in $before; do
        if ! printf '%s\n' "$after" | grep -qix "$w"; then
            if xdotool getwindowname "$w" >/dev/null 2>&1; then
                xdotool windowunmap "$w" 2>/dev/null
                sleep 0.2
                xdotool windowmap "$w" 2>/dev/null
                sleep 0.3
            fi
        fi
    done
    return 0
}

# Recreating desktops via `bspc monitor -d NAMES...` can also leave a
# window's real desktop out of sync with the `_NET_WM_DESKTOP` EWMH
# property it broadcasts (bspwm doesn't always re-emit it after some
# desktop teardown/recreate paths). Indicators that read that property
# directly (e.g. polybar's xworkspaces module) then show the wrong
# desktop as occupied/empty even though bspwm itself is fine. Fix by
# bouncing every managed window off a scratch desktop and back, which
# makes bspwm recompute and rebroadcast the correct index.
resync_ewmh_desktops() {
    local all_desktops
    all_desktops=$(bspc query -D --names 2>/dev/null)
    for w in $(managed_windows); do
        local real scratch
        real=$(bspc query -D -n "$w" --names 2>/dev/null) || continue
        [ -z "$real" ] && continue
        scratch=$(printf '%s\n' "$all_desktops" | grep -vx "$real" | head -n1)
        [ -z "$scratch" ] && continue
        bspc node "$w" -d "$scratch" >/dev/null 2>&1 || continue
        bspc node "$w" -d "$real" >/dev/null 2>&1 || true
    done
    return 0
}

before_windows=$(managed_windows)

# xrandr changes the root window's geometry, which leaves feh's
# already-set background stale/mispositioned. Re-apply it on every
# layout change; feh --bg-fill covers every active output on its own.
apply_wallpaper() {
    [ -f "$WALLPAPER" ] && /usr/bin/feh --bg-fill "$WALLPAPER"
}

# bspwm needs a moment to process a RandR change (output added/removed)
# before monitor/desktop commands referencing it will succeed. Retry
# instead of a fixed sleep. Written with `if` so a failing attempt
# doesn't trip `set -e`.
retry() {
    for _ in $(seq 1 10); do
        if "$@" >/dev/null 2>&1; then
            return 0
        fi
        sleep 0.3
    done
    return 1
}

wait_for_monitor() {
    for _ in $(seq 1 10); do
        if bspc query -M --names 2>/dev/null | grep -qx "$1"; then
            return 0
        fi
        sleep 0.3
    done
    return 1
}

# drop bspwm monitor objects left behind by outputs that are now off;
# harmless no-op for outputs that never had one (e.g. never-used DP ports)
drop_disabled_monitors() {
    for out in $(xrandr --query | awk '/ disconnected/{print $1}'); do
        bspc monitor "$out" -r >/dev/null 2>&1 || true
    done
}

reset_single() {
    xrandr --output "$PRIMARY" --auto --primary
    for out in $(xrandr --query | awk '/ disconnected/{print $1}'); do
        xrandr --output "$out" --off
    done
    retry bspc monitor "$PRIMARY" -d I II III IV V VI VII VIII IX X || true
    drop_disabled_monitors
    reclaim_lost_windows "$before_windows"
    resync_ewmh_desktops
    apply_wallpaper
    ~/.config/polybar/launch.sh --custom
    notify-send "Monitor" "1 pantalla (eDP), 10 escritorios" 2>/dev/null || true
}

if [ -z "$secondary" ]; then
    reset_single
    exit 0
fi

# rofi exits non-zero when the menu is cancelled (Escape / closed) —
# that's a normal, expected outcome here (handled right below by the
# `-z "$choice"` check), not a real error; don't let pipefail abort
# the script over it.
choice=$(printf 'Derecha\nIzquierda\nArriba\nAbajo\nEspejo\nDesactivar %s' "$secondary" \
    | rofi -dmenu -p "Posición de $secondary" || true)

[ -z "$choice" ] && exit 0

if [ "$choice" = "Desactivar $secondary" ]; then
    xrandr --output "$secondary" --off --output "$PRIMARY" --auto --primary
    retry bspc monitor "$PRIMARY" -d I II III IV V VI VII VIII IX X || true
    drop_disabled_monitors
    reclaim_lost_windows "$before_windows"
    resync_ewmh_desktops
    apply_wallpaper
    ~/.config/polybar/launch.sh --custom
    notify-send "Monitor" "$secondary desactivado, 1 pantalla" 2>/dev/null || true
    exit 0
fi

case "$choice" in
    Derecha)   xrandr --output "$PRIMARY" --auto --primary --output "$secondary" --auto --right-of "$PRIMARY" ;;
    Izquierda) xrandr --output "$PRIMARY" --auto --primary --output "$secondary" --auto --left-of  "$PRIMARY" ;;
    Arriba)    xrandr --output "$PRIMARY" --auto --primary --output "$secondary" --auto --above    "$PRIMARY" ;;
    Abajo)     xrandr --output "$PRIMARY" --auto --primary --output "$secondary" --auto --below    "$PRIMARY" ;;
    Espejo)    xrandr --output "$PRIMARY" --auto --primary --output "$secondary" --auto --same-as  "$PRIMARY" ;;
    *) exit 0 ;;
esac

# wait for bspwm to pick up the new randr output before touching its desktops
wait_for_monitor "$secondary"

if [ "$choice" = "Espejo" ]; then
    retry bspc monitor "$PRIMARY" -d I II III IV V VI VII VIII IX X || true
else
    retry bspc monitor "$PRIMARY"   -d I II III IV V || true
    retry bspc monitor "$secondary" -d VI VII VIII IX X || true
fi

reclaim_lost_windows "$before_windows"
resync_ewmh_desktops
apply_wallpaper
~/.config/polybar/launch.sh --custom
notify-send "Monitor" "$secondary: $choice" 2>/dev/null || true
