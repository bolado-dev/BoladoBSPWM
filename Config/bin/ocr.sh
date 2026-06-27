#!/usr/bin/env bash
# OCR de una región: selecciona con el ratón -> texto al portapapeles.
# Requiere: tesseract-ocr + (maim|scrot) + xclip.   Bind sugerido: Super+Shift+S
set -e

if ! command -v tesseract >/dev/null 2>&1; then
    command -v notify-send >/dev/null 2>&1 && notify-send -u critical "OCR" "Falta tesseract-ocr"
    exit 1
fi

img="$(mktemp --suffix=.png)"
trap 'rm -f "$img" "$img.txt"' EXIT

# Captura de región (maim si está; si no, scrot)
if command -v maim >/dev/null 2>&1; then
    maim -s "$img" || exit 0
else
    scrot -s "$img" || exit 0
fi

# Idiomas: inglés + español si está el paquete
langs=eng
tesseract --list-langs 2>/dev/null | grep -qx spa && langs=eng+spa

tesseract "$img" "${img%.png}" -l "$langs" >/dev/null 2>&1
txt="$(cat "${img%.png}.txt" 2>/dev/null)"

if [ -n "$txt" ]; then
    printf '%s' "$txt" | xclip -selection clipboard
    command -v notify-send >/dev/null 2>&1 && notify-send -u low "OCR" "Texto copiado al portapapeles"
else
    command -v notify-send >/dev/null 2>&1 && notify-send -u normal "OCR" "No se reconoció texto"
fi
