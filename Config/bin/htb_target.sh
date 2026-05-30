#!/bin/sh
# Muestra el target activo en polybar leyendo el bloque que gestiona `settarget`
# en /etc/hosts (marcas "# [settarget] BEGIN" ... "# [settarget] END").

HOSTS_FILE="/etc/hosts"

# Última entrada "IP HOST" dentro del bloque [settarget] (el target activo).
line=$(awk '
  /^# \[settarget\] BEGIN/ { inblk=1; next }
  /^# \[settarget\] END/   { inblk=0; next }
  inblk && NF { last=$0 }
  END { print last }
' "$HOSTS_FILE" 2>/dev/null)

ip_target=$(printf '%s\n' "$line" | awk '{print $1}')
name_target=$(printf '%s\n' "$line" | awk '{print $2}')

if [ -n "$ip_target" ] && [ -n "$name_target" ]; then
	echo "%{F#e51d0b}什%{F#ffffff} $ip_target - $name_target"
elif [ -n "$ip_target" ]; then
	echo "%{F#e51d0b}什%{F#ffffff} $ip_target"
else
	echo "%{F#e51d0b}ﲅ %{u-}%{F#ffffff} No target"
fi
