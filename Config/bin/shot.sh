#!/usr/bin/env bash
# Screenshot que guarda en la carpeta del TARGET activo (content/) si lo hay,
# o en ~/ScreenShots como fallback. Copia también al portapapeles.
#   shot.sh region   -> selección interactiva (flameshot gui)
#   shot.sh full     -> pantalla completa
#   shot.sh clip     -> pantalla completa solo al portapapeles
TARGET_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/htb_target"
HTB_ROOT="${HTB_ROOT:-$HOME/HTB}"

name="$(awk '{print $2}' "$TARGET_FILE" 2>/dev/null)"
if [ -n "$name" ] && [ -d "$HTB_ROOT/$name" ]; then
    dest="$HTB_ROOT/$name/content"
else
    dest="$HOME/ScreenShots"
fi
mkdir -p "$dest"

case "${1:-region}" in
    region) flameshot gui   -p "$dest" -c ;;
    full)   flameshot full  -p "$dest" -c ;;
    clip)   flameshot full  -c ;;
    *)      flameshot gui   -p "$dest" -c ;;
esac
