#!/usr/bin/env bash
# Reproductor (MPRIS vía playerctl) para polybar — compacto.
# Muestra "<icono> Artista - Título" truncado. No imprime nada si no suena nada.

status="$(playerctl status 2>/dev/null)" || exit 0
[ -z "$status" ] && exit 0

case "$status" in
    Playing) icon=$'\uf001' ;;   # nota musical (nf-fa-music)
    Paused)  icon=$'\uf04c' ;;   # pausa (nf-fa-pause)
    *)       exit 0 ;;
esac

meta="$(playerctl metadata --format '{{artist}} - {{title}}' 2>/dev/null)"
if [ -z "$meta" ] || [ "$meta" = " - " ]; then
    meta="$(playerctl metadata --format '{{title}}' 2>/dev/null)"
fi
[ -z "$meta" ] && exit 0

max=35
if [ "${#meta}" -gt "$max" ]; then
    meta="${meta:0:$max}…"
fi

printf '%s %s\n' "$icon" "$meta"
