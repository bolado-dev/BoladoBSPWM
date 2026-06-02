#!/usr/bin/env bash
# Selector de modo de energía (power-profiles-daemon) con rofi.
# Se abre al hacer click en la batería / indicador de modo de polybar.

if ! command -v powerprofilesctl >/dev/null 2>&1; then
    command -v notify-send >/dev/null && notify-send "Energía" "Instala power-profiles-daemon"
    exit 0
fi

cur="$(powerprofilesctl get 2>/dev/null)"

# perfiles: solo las cabeceras (líneas que terminan en ':'), no las propiedades
mapfile -t profs < <(powerprofilesctl list 2>/dev/null | sed -nE 's/^[* ]*([a-z-]+):$/\1/p')
[ "${#profs[@]}" -eq 0 ] && profs=(performance balanced power-saver)

# iconos con sentido: rayo=rendimiento, balanza=equilibrado, hoja=ahorro
declare -A ic=(
    [performance]=$'\uf0e7  Rendimiento'
    [balanced]=$'\uf24e  Equilibrado'
    [power-saver]=$'\uf06c  Ahorro'
)

opts=""
for p in "${profs[@]}"; do
    label="${ic[$p]:-$p}"
    [ "$p" = "$cur" ] && label="$label  ●"
    opts+="${label}\n"
done

sel="$(echo -e "$opts" | rofi -dmenu -i -p "" \
        -theme ~/.config/rofi-mono.rasi \
        -theme-str 'configuration { show-icons: false; } window { width: 22%; } listview { lines: 3; } mainbox { children: [ listview ]; }')"

case "$sel" in
    *Rendimiento*) powerprofilesctl set performance ;;
    *Equilibrado*) powerprofilesctl set balanced ;;
    *Ahorro*)      powerprofilesctl set power-saver ;;
esac
