#!/bin/sh
# Lee el target activo de ~/.config/htb_target (escrito por settarget)
TARGET_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/htb_target"

line=$(cat "$TARGET_FILE" 2>/dev/null)
ip_target=$(printf '%s\n'  "$line" | awk '{print $1}')
name_target=$(printf '%s\n' "$line" | awk '{print $2}')

if [ -n "$ip_target" ] && [ -n "$name_target" ]; then
    echo "%{F#957FB8}ﲅ %{F#DCD7BA} $ip_target - $name_target"
elif [ -n "$ip_target" ]; then
    echo "%{F#957FB8}ﲅ %{F#DCD7BA} $ip_target"
else
    echo "%{F#54546D}ﲅ %{F#54546D} No target"
fi
