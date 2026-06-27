#!/usr/bin/env bash
# "Modo limpio" para compartir pantalla / grabar:
# alterna gaps (6<->0) y oculta/muestra la polybar.   Bind sugerido: Super+F12
FLAG="/tmp/bolado-clean.flag"

if [ -f "$FLAG" ]; then
    # Volver a normal
    bspc config window_gap 6
    command -v polybar-msg >/dev/null 2>&1 && polybar-msg cmd show >/dev/null 2>&1
    rm -f "$FLAG"
    command -v notify-send >/dev/null 2>&1 && notify-send -u low "modo limpio" "off"
else
    # Limpio: sin gaps, sin barra
    bspc config window_gap 0
    command -v polybar-msg >/dev/null 2>&1 && polybar-msg cmd hide >/dev/null 2>&1
    touch "$FLAG"
    command -v notify-send >/dev/null 2>&1 && notify-send -u low "modo limpio" "on"
fi
