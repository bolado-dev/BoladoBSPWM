#!/usr/bin/env bash
# Toggle de la VPN de HTB — pensado para click en la polybar (módulo htb_status).
# Si tun0 está arriba -> desconecta. Si no -> conecta ~/VPNs/htb.ovpn.
# Abre una kitty para pedir la contraseña de sudo / mostrar los logs de openvpn.

OVPN="${HTB_OVPN:-$HOME/VPNs/htb.ovpn}"

if ip -o link show tun0 >/dev/null 2>&1; then
    # Conectada -> desconectar (en terminal por el sudo)
    kitty --class float-help --title "VPN · desconectar" \
        sh -c 'echo "Cerrando OpenVPN…"; sudo pkill -INT -x openvpn; sleep 1; echo "hecho."; sleep 1' &
else
    # Desconectada -> conectar
    if [ ! -f "$OVPN" ]; then
        command -v notify-send >/dev/null 2>&1 && notify-send -u critical "VPN" "No existe $OVPN"
        exit 1
    fi
    kitty --class float-help --title "VPN · $OVPN" \
        sh -c "echo 'Conectando OpenVPN ($OVPN)…'; sudo openvpn '$OVPN'" &
fi
