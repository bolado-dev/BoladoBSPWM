#!/usr/bin/env bash
# Reproductor para polybar (MPRIS vía playerctl).
# Muestra botones ⏮  ⏯  ⏭ (clicables) + el título de la canción.
# No imprime nada si no hay reproductor activo.

status="$(playerctl status 2>/dev/null)" || exit 0
case "$status" in
    Playing|Paused) : ;;
    *) exit 0 ;;
esac

title="$(playerctl metadata --format '{{title}}' 2>/dev/null)"
[ -z "$title" ] && exit 0

max=40
if [ "${#title}" -gt "$max" ]; then
    title="${title:0:$max}…"
fi

prev=$'\uf048'                                   # nf-fa-step-backward
next=$'\uf051'                                   # nf-fa-step-forward
if [ "$status" = "Playing" ]; then
    pp=$'\uf04c'                                 # nf-fa-pause
else
    pp=$'\uf04b'                                 # nf-fa-play
fi

# botones clicables con áreas de acción de polybar (%{A1:cmd:}...%{A})
b_prev="%{A1:playerctl previous:}${prev}%{A}"
b_pp="%{A1:playerctl play-pause:}${pp}%{A}"
b_next="%{A1:playerctl next:}${next}%{A}"

echo "${b_prev}  ${b_pp}  ${b_next}  ${title}"
