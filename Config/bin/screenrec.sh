#!/usr/bin/env bash
# Toggle de grabación de pantalla (para PoCs/writeups).
# 1ª pulsación: elige región con el ratón y graba. 2ª: para y guarda en ~/Videos.
# Requiere: ffmpeg + slop.   Bind sugerido: Super+Shift+R
PIDFILE="/tmp/bolado-screenrec.pid"
OUTDIR="$HOME/Videos"

stop() {
    kill -INT "$(cat "$PIDFILE")" 2>/dev/null
    rm -f "$PIDFILE"
    command -v notify-send >/dev/null 2>&1 && notify-send -u low "REC" "Grabación detenida → $OUTDIR"
}

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    stop; exit 0
fi

for b in ffmpeg slop; do
    command -v "$b" >/dev/null 2>&1 || { notify-send -u critical "REC" "Falta $b" 2>/dev/null; exit 1; }
done

mkdir -p "$OUTDIR"
read -r W H X Y < <(slop -f "%w %h %x %y") || exit 0
# ffmpeg exige dimensiones pares
W=$((W - W % 2)); H=$((H - H % 2))
out="$OUTDIR/rec-$(date +%Y%m%d-%H%M%S).mp4"

ffmpeg -y -f x11grab -framerate 30 -video_size "${W}x${H}" -i "${DISPLAY}+${X},${Y}" \
       -c:v libx264 -preset ultrafast -pix_fmt yuv420p "$out" >/dev/null 2>&1 &
echo $! > "$PIDFILE"
command -v notify-send >/dev/null 2>&1 && notify-send -u low "REC" "Grabando ${W}x${H} — repite el atajo para parar"
