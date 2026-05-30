#!/bin/bash
#
# BoladoBSPWM · adaptación a hardware
# Ajusta los configs YA instalados en ~/.config según la máquina:
#   - batería (nombre real o quitar módulo si no hay)
#   - red (wifi vs ethernet, interfaz real)
#   - monitores (disposición dual personalizada)
#   - drivers de GPU (NVIDIA / AMD / Intel)
#
# Se puede ejecutar suelto:  ./hardware.sh
#

green="\033[1;32m"; amber="\033[1;33m"; red="\033[1;31m"; reset="\033[0m"
log()  { echo -e "${amber}[*]${reset} $1"; }
ok()   { echo -e "${green}[+]${reset} $1"; }
warn() { echo -e "${red}[!]${reset} $1"; }
ask()  { local r; read -p "$(echo -e "${amber}[?]${reset} $1 [s/N] ")" r; [[ "$r" =~ ^[sSyY] ]]; }

CUR="$HOME/.config/polybar/current.ini"
BSPWMRC="$HOME/.config/bspwm/bspwmrc"
LAUNCH="$HOME/.config/polybar/launch.sh"
PICOM="$HOME/.config/picom/picom.conf"

# ─────────────────────────────────────────────
# Batería
# ─────────────────────────────────────────────
adapt_battery() {
    local bat adp
    bat=$(ls /sys/class/power_supply/ 2>/dev/null | grep -iE '^BAT'        | head -1)
    adp=$(ls /sys/class/power_supply/ 2>/dev/null | grep -iE '^(ADP|AC)'   | head -1)

    if [ -z "$bat" ]; then
        warn "Sin batería (PC de sobremesa). Quitando el módulo 'battery' de la pill."
        BB_REMOVE_BATTERY=1 python3 "$(dirname "$0")/.bb_polybar.py" "$CUR"
    else
        BB_BAT="$bat" BB_ADP="${adp:-ADP0}" python3 "$(dirname "$0")/.bb_polybar.py" "$CUR"
        ok "Batería: $bat · adaptador: ${adp:-ADP0}"
    fi
}

# ─────────────────────────────────────────────
# Red (wifi / ethernet)
# ─────────────────────────────────────────────
adapt_network() {
    local wifi="" iface="" d n
    for d in /sys/class/net/*; do
        [ -d "$d/wireless" ] && wifi=$(basename "$d") && break
    done
    iface="$wifi"
    if [ -z "$iface" ]; then
        iface=$(ip route 2>/dev/null | awk '/^default/{print $5; exit}')
        if [ -z "$iface" ]; then
            for d in /sys/class/net/*; do
                n=$(basename "$d"); [ "$n" = lo ] && continue
                [ "$(cat "$d/operstate" 2>/dev/null)" = up ] && iface="$n" && break
            done
        fi
        [ -z "$iface" ] && iface=$(ls /sys/class/net 2>/dev/null | grep -v '^lo$' | head -1)
    fi
    [ -z "$iface" ] && { warn "No detecto interfaz de red; dejo la del config."; return; }

    if [ -n "$wifi" ]; then
        BB_IFACE="$iface" BB_NETTYPE="wireless" python3 "$(dirname "$0")/.bb_polybar.py" "$CUR"
        ok "Red wifi: $iface"
    else
        BB_IFACE="$iface" BB_NETTYPE="wired" python3 "$(dirname "$0")/.bb_polybar.py" "$CUR"
        ok "Red cableada: $iface"
    fi
}

# ─────────────────────────────────────────────
# Monitores (disposición dual personalizada)
# ─────────────────────────────────────────────
adapt_monitors() {
    if [ -z "$DISPLAY" ]; then
        warn "Sin sesión X activa; salto la config de monitores (córrela dentro de bspwm)."
        return
    fi
    local mons n primary secondary pos line
    mapfile -t mons < <(xrandr --query 2>/dev/null | awk '/ connected/{print $1}')
    n=${#mons[@]}
    if [ "$n" -le 1 ]; then
        ok "Un solo monitor (${mons[0]:-desconocido}). Sin cambios."
        return
    fi

    log "Detectados $n monitores: ${mons[*]}"
    ask "¿Configurar disposición dual personalizada?" || { warn "Omitido."; return; }

    echo "Monitores: ${mons[*]}"
    read -p "$(echo -e "${amber}[?]${reset} Monitor PRIMARIO (def ${mons[0]}): ")" primary
    primary=${primary:-${mons[0]}}
    read -p "$(echo -e "${amber}[?]${reset} Monitor SECUNDARIO (def ${mons[1]}): ")" secondary
    secondary=${secondary:-${mons[1]}}

    echo "Posición del secundario respecto al primario:"
    echo "  1) a la derecha   2) a la izquierda   3) encima   4) debajo"
    read -p "$(echo -e "${amber}[?]${reset} Opción (def 1): ")" pos
    case "$pos" in
        2) pos="--left-of" ;;
        3) pos="--above" ;;
        4) pos="--below" ;;
        *) pos="--right-of" ;;
    esac

    line="xrandr --output $primary --primary --auto --output $secondary --auto $pos $primary"

    # Insertar/actualizar la línea xrandr en bspwmrc (bajo el marcador RESOLUCION ARANDR)
    if grep -q '^xrandr --output' "$BSPWMRC"; then
        sed -i "s|^xrandr --output.*|$line|" "$BSPWMRC"
    elif grep -q 'RESOLUCION ARANDR' "$BSPWMRC"; then
        sed -i "s|.*RESOLUCION ARANDR.*|# RESOLUCION ARANDR\n$line|" "$BSPWMRC"
    else
        sed -i "0,/^bspc monitor/s||$line\n\nbspc monitor|" "$BSPWMRC"
    fi

    # Repartir escritorios entre monitores (1-5 / 6-10)
    if grep -qE '^bspc monitor -d ' "$BSPWMRC"; then
        sed -i "s|^bspc monitor -d .*|bspc monitor \"$primary\" -d 1 2 3 4 5\nbspc monitor \"$secondary\" -d 6 7 8 9 10|" "$BSPWMRC"
    fi

    # Polybar pill en CADA monitor
    sed -i 's|^monitor =.*|monitor = ${env:MONITOR:}|' "$CUR"   # solo afecta a [bar/pill] si es su línea
    python3 "$(dirname "$0")/.bb_polybar.py" "$CUR" pillmonitor
    cat > "$LAUNCH" <<'LAUNCHEOF'
#!/usr/bin/env sh
killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

## Pill en cada monitor conectado
if command -v polybar >/dev/null; then
    for m in $(polybar -m | cut -d: -f1); do
        MONITOR=$m polybar pill -c ~/.config/polybar/current.ini &
    done
fi
LAUNCHEOF
    chmod +x "$LAUNCH"
    ok "Dual monitor: $primary (primario) + $secondary ($pos). Escritorios 1-5/6-10. Polybar por monitor."
    log "Disposición aplicada: $line"
}

# ─────────────────────────────────────────────
# Drivers de GPU
# ─────────────────────────────────────────────
adapt_drivers() {
    local gpu
    gpu=$(lspci 2>/dev/null | grep -iE 'vga compatible|3d controller')
    [ -z "$gpu" ] && { warn "No puedo leer la GPU (lspci)."; return; }
    log "GPU: $(echo "$gpu" | sed 's/.*: //' | paste -sd' / ')"

    if echo "$gpu" | grep -qi nvidia; then
        warn "GPU NVIDIA detectada."
        if ask "¿Instalar driver NVIDIA + firmware?"; then
            sudo apt install -y nvidia-driver firmware-misc-nonfree
        fi
        # glx suele ir mejor que xrender en NVIDIA
        if [ -f "$PICOM" ]; then
            if grep -q '^backend' "$PICOM"; then
                sed -i 's/^backend.*/backend = "glx";/' "$PICOM"
            else
                echo 'backend = "glx";' >> "$PICOM"
            fi
            ok "picom: backend = glx (recomendado en NVIDIA)."
        fi
    elif echo "$gpu" | grep -qiE 'amd|radeon|\bati\b'; then
        warn "GPU AMD/Radeon detectada."
        ask "¿Instalar firmware AMD + Mesa/Vulkan?" && \
            sudo apt install -y firmware-amd-graphics mesa-vulkan-drivers libgl1-mesa-dri
    elif echo "$gpu" | grep -qi intel; then
        ok "GPU Intel (driver en kernel/Mesa, normalmente sin acción)."
        ask "¿Instalar Mesa + intel-media-va-driver (aceleración VA-API)?" && \
            sudo apt install -y mesa-va-drivers intel-media-va-driver
    else
        warn "GPU no reconocida automáticamente; revisa drivers a mano."
    fi
}

# ─────────────────────────────────────────────
# Touchpad (2 dedos = click derecho, no esquinas)
# ─────────────────────────────────────────────
adapt_touchpad() {
    if ! grep -qiE 'touchpad' /proc/bus/input/devices 2>/dev/null; then
        ok "Sin touchpad detectado; salto su configuración."
        return
    fi
    local src
    src="$(dirname "$0")/x11/30-touchpad.conf"
    [ -f "$src" ] || { warn "Falta x11/30-touchpad.conf; salto."; return; }
    log "Configurando touchpad (2 dedos = click derecho)..."
    if sudo install -Dm644 "$src" /etc/X11/xorg.conf.d/30-touchpad.conf; then
        ok "Touchpad configurado. Efectivo al reiniciar X (cierra sesión y entra)."
    else
        warn "No se pudo instalar la regla del touchpad."
    fi
}

main() {
    echo -e "${amber}== Adaptación a hardware ==${reset}"
    adapt_battery
    adapt_network
    adapt_touchpad
    adapt_monitors
    adapt_drivers
    echo -e "${green}== Hardware adaptado ==${reset}"
}

# Si se ejecuta directamente, corre todo
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
