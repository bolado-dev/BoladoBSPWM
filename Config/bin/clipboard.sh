#!/usr/bin/env bash
# Historial de portapapeles buscable (greenclip) con el tema mono de rofi.
# Bind sugerido: Super+V.   El daemon se arranca en bspwmrc.
if ! command -v greenclip >/dev/null 2>&1; then
    command -v notify-send >/dev/null 2>&1 && notify-send -u critical "clipboard" "Falta greenclip"
    exit 1
fi
rofi -modi 'clipboard:greenclip print' -show clipboard \
     -theme ~/.config/rofi-mono.rasi \
     -run-command '{cmd}' -p 'clip'
