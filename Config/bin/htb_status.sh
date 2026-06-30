#!/bin/sh
# Estado de la VPN (HTB / cualquier OpenVPN | WireGuard | tap | ppp).
# Solo 2 estados — sin "Connecting…":
#   tun/tap/wg/ppp UP con IP   →  logo HTB + IP en blanco
#   sin túnel                   →  logo HTB + "Disconnected" en gris
#
# El glifo es U+F6A6 (Hack/Iosevka Nerd Font, icono oficial de HTB):
# en UTF-8 bytes EF 9A A6 = octal \357\232\246. Usamos printf para
# que el char se inyecte literal sin depender del editor.

HTB=$(printf '\357\232\246')

IP=""
for dev in $(ip -o link show 2>/dev/null \
              | awk -F': ' '/^[0-9]+: (tun|tap|wg|ppp)/{gsub(/@.*/,"",$2); print $2}'); do
	addr=$(ip -o -4 addr show "$dev" 2>/dev/null | awk '{print $4}' | cut -d/ -f1)
	if [ -n "$addr" ]; then IP="$addr"; break; fi
done

if [ -n "$IP" ]; then
	printf '%%{F#957FB8}%s %%{F#DCD7BA}%s%%{u-}\n' "$HTB" "$IP"
else
	printf '%%{F#54546D}%s %%{F#54546D}Disconnected%%{u-}\n' "$HTB"
fi
