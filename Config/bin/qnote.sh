#!/usr/bin/env bash
# Nota rápida con timestamp en el notes.md del target activo.
# Sin args: pide la nota por rofi (para keybind). Con args: la añade directa.
# Bind sugerido: Super+N
TARGET_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/htb_target"
HTB_ROOT="${HTB_ROOT:-$HOME/HTB}"

name="$(awk '{print $2}' "$TARGET_FILE" 2>/dev/null)"
dir="$HTB_ROOT/${name:-_scratch}"
mkdir -p "$dir"

if [ -n "$*" ]; then
    note="$*"
else
    note="$(rofi -dmenu -p 'nota' -theme ~/.config/rofi-mono.rasi -lines 0 < /dev/null)"
fi
[ -z "$note" ] && exit 0

printf -- '- [%s] %s\n' "$(date +%H:%M)" "$note" >> "$dir/notes.md"
command -v notify-send >/dev/null 2>&1 && notify-send -u low "nota guardada" "→ ${name:-_scratch}/notes.md"
