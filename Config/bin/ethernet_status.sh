#!/bin/sh
# IP wifi en blanco con icono en violeta acento. Si no hay IP, todo en gris.
IP=$(/usr/sbin/ifconfig wlan0 2>/dev/null | awk '/inet /{print $2; exit}')
if [ -n "$IP" ]; then
	echo "%{F#ffb300} %{F#f0f0f0}$IP%{u-}"
else
	echo "%{F#5a5a5a} %{F#5a5a5a}—%{u-}"
fi
