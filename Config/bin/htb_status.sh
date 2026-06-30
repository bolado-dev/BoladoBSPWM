#!/bin/sh
# Estado de la VPN (HTB / cualquier OpenVPN | WireGuard | tap | ppp).
# Estados:
#   tun/tap/wg/ppp UP con IP  →  IP en verde
#   proc openvpn/wg vivo pero sin túnel  →  "Connecting…" en amarillo
#   nada                                  →  "Disconnected" en rojo
#
# Polybar reformatea con %{F#...}. interval = 2s en current.ini.

# 1) Busca cualquier interfaz VPN-like con IPv4 asignada
IP=""
IFACE=""
for dev in $(ip -o link show 2>/dev/null \
              | awk -F': ' '/^[0-9]+: (tun|tap|wg|ppp)/{gsub(/@.*/,"",$2); print $2}'); do
	addr=$(ip -o -4 addr show "$dev" 2>/dev/null | awk '{print $4}' | cut -d/ -f1)
	if [ -n "$addr" ]; then
		IP="$addr"
		IFACE="$dev"
		break
	fi
done

if [ -n "$IP" ]; then
	echo "%{F#76946A} %{F#DCD7BA}$IP%{u-}"
	exit 0
fi

# 2) Sin túnel pero algún demonio VPN está vivo → "Connecting…"
if pgrep -x openvpn >/dev/null 2>&1 \
   || pgrep -x wg-quick >/dev/null 2>&1 \
   || pgrep -af "openconnect|nm-openvpn-service" >/dev/null 2>&1; then
	echo "%{F#DCA561} %{F#DCA561}Connecting…%{u-}"
	exit 0
fi

# 3) Nada → desconectado
echo "%{F#C34043} %{F#54546D}Disconnected%{u-}"
