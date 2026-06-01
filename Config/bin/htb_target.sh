#!/bin/sh
# Lee el target activo de ~/.config/htb_target (escrito por settarget)
TARGET_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/htb_target"

line=$(cat "$TARGET_FILE" 2>/dev/null)
ip_target=$(printf '%s\n'  "$line" | awk '{print $1}')
name_target=$(printf '%s\n' "$line" | awk '{print $2}')

if [ -n "$ip_target" ] && [ -n "$name_target" ]; then
    echo "%{F#e51d0b}ﲅ %{F#ffffff} $ip_target - $name_target"
elif [ -n "$ip_target" ]; then
    echo "%{F#e51d0b}ﲅ %{F#ffffff} $ip_target"
else
    echo "%{F#e51d0b}ﲅ %{u-}%{F#ffffff} No target"
fi
