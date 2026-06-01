#!/usr/bin/env bash
# Indicador del modo de energía actual para polybar.
# Sin batería: fuerza rendimiento y no muestra nada (no tiene sentido el selector).
command -v powerprofilesctl >/dev/null 2>&1 || exit 0
if ! ls /sys/class/power_supply/ 2>/dev/null | grep -qiE '^BAT'; then
    powerprofilesctl set performance 2>/dev/null
    exit 0
fi
case "$(powerprofilesctl get 2>/dev/null)" in
    performance) echo $'\uf0e7' ;;
    balanced)    echo $'\uf24e' ;;
    power-saver) echo $'\uf06c' ;;
esac
