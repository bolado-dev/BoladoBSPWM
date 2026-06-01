#!/usr/bin/env sh

## Add this to your wm startup file.

# Terminate already running bar instances
killall -q polybar

## Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

## Una barra "pill" por cada monitor conectado.
## Con `monitor = ${env:MONITOR:}` en [bar/pill] + `pin-workspaces = true`,
## cada monitor muestra solo sus workspaces. Funciona igual con 1 o varios.
if type xrandr >/dev/null 2>&1; then
    for m in $(polybar -m | cut -d: -f1); do
        MONITOR=$m polybar pill -c ~/.config/polybar/current.ini &
    done
else
    polybar pill -c ~/.config/polybar/current.ini &
fi
