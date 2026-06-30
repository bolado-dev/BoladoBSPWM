#!/bin/sh
# IP wifi en blanco con icono en violeta acento. Si no hay IP, todo en gris.
IP=$(/usr/sbin/ifconfig wlan0 2>/dev/null | awk '/inet /{print $2; exit}')
if [ -n "$IP" ]; then
	echo "%{F#957FB8} %{F#DCD7BA}$IP%{u-}"
else
	echo "%{F#54546D} %{F#54546D}—%{u-}"
fi
