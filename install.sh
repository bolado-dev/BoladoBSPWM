#!/usr/bin/env bash
#
#  ╭───────────────────────────────────────────────────────────────╮
#  │  BoladoBSPWM — instalador                                       │
#  │  Tema bspwm monocromo + barra polybar pill · prompt rounded     │
#  │  https://github.com/bolado-dev/BoladoBSPWM                      │
#  ╰───────────────────────────────────────────────────────────────╯
#
#  Uso:  ./install.sh [opciones]
#

set -uo pipefail

VERSION="1.0"
REPO="https://github.com/bolado-dev/BoladoBSPWM"
RUTA="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Opciones ───────────────────────────────────────────────────────
DO_DEPS=1; DO_ROOT=1; DO_HARDWARE=1; ASSUME_YES=0; HARDWARE_ONLY=0

usage() {
    cat <<EOF
BoladoBSPWM v$VERSION — instalador

Uso: ./install.sh [opciones]

  -y, --yes           Modo desatendido (no pregunta)
      --no-deps       No instalar paquetes apt
      --no-root       No configurar el prompt de root
      --no-hardware   No adaptar al hardware (batería/red/monitores/drivers/touchpad)
      --hardware-only Solo re-adaptar al hardware (no copia configs ni instala)
  -h, --help          Muestra esta ayuda

Sin opciones: instalación completa interactiva.
EOF
    exit 0
}

while [ $# -gt 0 ]; do
    case "$1" in
        -y|--yes)        ASSUME_YES=1 ;;
        --no-deps)       DO_DEPS=0 ;;
        --no-root)       DO_ROOT=0 ;;
        --no-hardware)   DO_HARDWARE=0 ;;
        --hardware-only) HARDWARE_ONLY=1 ;;
        -h|--help)       usage ;;
        *) echo "Opción desconocida: $1 (usa --help)"; exit 1 ;;
    esac
    shift
done

# ── Estilo / logging ───────────────────────────────────────────────
if [ -t 1 ]; then
    B=$'\e[1m'; DIM=$'\e[2m'; R=$'\e[0m'
    WHITE=$'\e[97m'; GREY=$'\e[90m'; GREEN=$'\e[32m'; YELLOW=$'\e[33m'; RED=$'\e[31m'
else
    B=""; DIM=""; R=""; WHITE=""; GREY=""; GREEN=""; YELLOW=""; RED=""
fi

STEP=0; STEPS=0
step()  { STEP=$((STEP+1)); printf "\n${B}${WHITE}[%d/%d] %s${R}\n" "$STEP" "$STEPS" "$1"; }
ok()    { printf "  ${GREEN}✓${R} %s\n" "$1"; }
info()  { printf "  ${GREY}·${R} %s\n" "$1"; }
warn()  { printf "  ${YELLOW}!${R} %s\n" "$1"; }
err()   { printf "  ${RED}✗${R} %s\n" "$1"; }
die()   { err "$1"; exit 1; }
confirm() {
    [ "$ASSUME_YES" -eq 1 ] && return 0
    printf "  ${YELLOW}?${R} %s ${DIM}[s/N]${R} " "$1"; read -r r; [[ "$r" =~ ^[sSyY] ]]
}

banner() {
    if [ -t 1 ]; then
        local c1=$'\e[38;5;244m' c2=$'\e[38;5;246m' c3=$'\e[38;5;248m'
        local c4=$'\e[38;5;250m' c5=$'\e[38;5;252m' c6=$'\e[38;5;254m'
        local c7=$'\e[38;5;255m'
    else
        local c1='' c2='' c3='' c4='' c5='' c6='' c7=''
    fi
    printf "${c1}%s${R}\n" ':::::::::   ::::::::  :::            :::     :::::::::   ::::::::  :::::::::   ::::::::  :::::::::  :::       ::: ::::    ::::  '
    printf "${c2}%s${R}\n" ':+:    :+: :+:    :+: :+:          :+: :+:   :+:    :+: :+:    :+: :+:    :+: :+:    :+: :+:    :+: :+:       :+: +:+:+: :+:+:+ '
    printf "${c3}%s${R}\n" '+:+    +:+ +:+    +:+ +:+         +:+   +:+  +:+    +:+ +:+    +:+ +:+    +:+ +:+        +:+    +:+ +:+       +:+ +:+ +:+:+ +:+ '
    printf "${c4}%s${R}\n" '+#++:++#+  +#+    +:+ +#+        +#++:++#++: +#+    +:+ +#+    +:+ +#++:++#+  +#++:++#++ +#++:++#+  +#+  +:+  +#+ +#+  +:+  +#+ '
    printf "${c5}%s${R}\n" '+#+    +#+ +#+    +#+ +#+        +#+     +#+ +#+    +#+ +#+    +#+ +#+    +#+        +#+ +#+        +#+ +#+#+ +#+ +#+       +#+ '
    printf "${c6}%s${R}\n" '#+#    #+# #+#    #+# #+#        #+#     #+# #+#    #+# #+#    #+# #+#    #+# #+#    #+# #+#         #+#+# #+#+#  #+#       #+# '
    printf "${c7}%s${R}\n" '#########   ########  ########## ###     ### #########   ########  #########   ########  ###          ###   ###   ###       ### '
    printf "  ${GREY}tema bspwm · monocromo + blanco · polybar pill · prompt rounded${R}\n"
    printf "  ${GREY}v%s · %s${R}\n" "$VERSION" "$REPO"
}

# ── Pre-flight ─────────────────────────────────────────────────────
preflight() {
    [ "$(id -u)" -eq 0 ] && die "No ejecutes el instalador como root (usa tu usuario; pedirá sudo cuando haga falta)."
    command -v apt >/dev/null || die "Este instalador asume Debian/Kali (apt no encontrado)."
    command -v sudo >/dev/null || die "Se necesita sudo."
}

# ════════════════════════════════════════════════════════════════════
#  Pasos
# ════════════════════════════════════════════════════════════════════
install_deps() {
    step "Instalando dependencias"
    info "Actualizando lista de paquetes..."
    sudo apt update -q
    info "Instalando paquetes (puede tardar varios minutos)..."
    sudo apt install -y \
        bspwm sxhkd polybar kitty rofi picom feh \
        flameshot brightnessctl playerctl pamixer i3lock \
        fastfetch imagemagick wmname libnotify-bin x11-utils \
        pavucontrol network-manager-gnome blueman wireplumber \
        zsh zsh-syntax-highlighting zsh-autosuggestions \
        git curl lsd bat fzf xclip scrot openvpn arandr autorandr power-profiles-daemon \
        fonts-font-awesome fontconfig \
        python3 pciutils x11-xserver-utils \
        lxappearance sassc gtk2-engines \
        && ok "Paquetes instalados" || warn "Algún paquete falló (revisa la salida de apt)"
    # Hack/3270 Nerd Font (iconos + dragón Kali), Source Code Pro y Montserrat no
    # están bien en apt: van bundleadas en Config/polybar/fonts y las pone install_fonts.
    # (fonts-hack de apt NO trae iconos Nerd Font, por eso usamos Hack Nerd Font bundleada).
}

install_fonts() {
    step "Instalando fuentes del tema (Nerd Font · Helvetica · feather)"
    local src="$RUTA/Config/polybar/fonts" fdir="$HOME/.local/share/fonts/BoladoBSPWM"
    if [ -d "$src" ]; then
        mkdir -p "$fdir"
        find "$src" -maxdepth 1 -type f \( -iname '*.ttf' -o -iname '*.otf' \) \
            -exec cp -f {} "$fdir/" \;
        fc-cache -f "$fdir" >/dev/null 2>&1
        local n; n=$(find "$fdir" -maxdepth 1 -type f \( -iname '*.ttf' -o -iname '*.otf' \) | wc -l)
        ok "$n fuentes → ~/.local/share/fonts (Hack/3270/Iosevka/Hurmit Nerd Font · dragón Kali U+F327 · Helvetica · Source Code Pro · Montserrat)"
    else
        warn "no encuentro las fuentes del repo en $src"
    fi
}

install_themes() {
    step "Temas WhiteSur (GTK · iconos · cursores)"
    local tmp; tmp="$(mktemp -d)"

    _ws() {  # $1 url  $2 etiqueta  (resto = args del install.sh del tema)
        local url="$1" tag="$2"; shift 2
        local d="$tmp/$tag"

        info "── Clonando WhiteSur $tag…"
        if ! git clone --depth=1 "$url" "$d"; then
            warn "WhiteSur $tag: git clone falló (sin red o repo no disponible)"
            return 1
        fi

        if [ ! -x "$d/install.sh" ]; then
            warn "WhiteSur $tag: install.sh no encontrado o no ejecutable"
            return 1
        fi

        info "── Instalando WhiteSur $tag…"
        if ( cd "$d" && ./install.sh "$@" ); then
            ok "WhiteSur $tag instalado"
        else
            warn "WhiteSur $tag: el instalador terminó con error"
            return 1
        fi
    }

    _ws https://github.com/vinceliuice/WhiteSur-gtk-theme.git  gtk
    _ws https://github.com/vinceliuice/WhiteSur-icon-theme.git iconos
    _ws https://github.com/vinceliuice/WhiteSur-cursors.git    cursores

    rm -rf "$tmp"

    # GTK2 (el de GTK3 va bundleado en Config/gtk-3.0/settings.ini)
    cat > "$HOME/.gtkrc-2.0" <<'G2'
gtk-theme-name="WhiteSur-Dark"
gtk-icon-theme-name="WhiteSur-dark"
gtk-cursor-theme-name="WhiteSur-cursors"
gtk-font-name="Sans 10"
G2
    ok "WhiteSur instalado y aplicado (ajústalo con lxappearance si quieres)"
}

backup_configs() {
    step "Copia de seguridad de tu config actual"
    local stamp d any=0
    stamp="$(date +%Y%m%d-%H%M%S)"
    for d in bspwm sxhkd polybar kitty picom bin; do
        if [ -e "$HOME/.config/$d" ]; then
            mv "$HOME/.config/$d" "$HOME/.config/$d.bak-$stamp"; any=1
            info "~/.config/$d → ~/.config/$d.bak-$stamp"
        fi
    done
    [ -e "$HOME/.zshrc" ]   && cp "$HOME/.zshrc"   "$HOME/.zshrc.bak-$stamp"   && any=1
    [ -e "$HOME/.p10k.zsh" ] && cp "$HOME/.p10k.zsh" "$HOME/.p10k.zsh.bak-$stamp" && any=1
    [ "$any" -eq 1 ] && ok "Backups creados (sufijo .bak-$stamp)" || ok "Nada que respaldar"
}

copy_configs() {
    step "Instalando configuración del tema"
    mkdir -p "$HOME/.config"
    cp -rf "$RUTA"/Config/* "$HOME/.config/"
    ok "bspwm · sxhkd · polybar · kitty · picom · bin"
    cp -f "$RUTA"/rofi/rofi-mono.rasi "$HOME/.config/"
    ok "tema rofi (~/.config/rofi-mono.rasi)"
    # Override de Chrome: usa EGL en vez de GLX para evitar freezes con picom
    if [ -f "$RUTA/Config/applications/google-chrome.desktop" ]; then
        mkdir -p "$HOME/.local/share/applications"
        cp -f "$RUTA/Config/applications/google-chrome.desktop" "$HOME/.local/share/applications/"
        ok "google-chrome.desktop → ~/.local/share/applications (--use-gl=egl)"
    fi
}

setup_zsh() {
    step "Configurando zsh + Powerlevel10k"
    cp -f "$RUTA"/zsh/.zshrc        "$HOME/.zshrc"
    cp -f "$RUTA"/zsh/.p10k.zsh     "$HOME/.p10k.zsh"
    cp -f "$RUTA"/zsh/p10k-mono.zsh "$HOME/.config/p10k-mono.zsh"
    # plugin "sudo" (Esc-Esc antepone sudo) vendorizado en el repo
    if [ -f "$RUTA/zsh/plugins/sudo.plugin.zsh" ]; then
        install -Dm644 "$RUTA"/zsh/plugins/sudo.plugin.zsh "$HOME/.config/zsh/sudo.plugin.zsh"
    fi
    grep -q 'p10k-mono.zsh' "$HOME/.zshrc" || \
        echo '[[ -f ~/.config/p10k-mono.zsh ]] && source ~/.config/p10k-mono.zsh' >> "$HOME/.zshrc"
    if [ ! -d "$HOME/.powerlevel10k" ]; then
        info "clonando Powerlevel10k…"
        git clone -q --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.powerlevel10k"
    fi
    [ -f "$RUTA"/scripts/kitty_start ] && \
        sudo install -m755 "$RUTA"/scripts/kitty_start /usr/local/bin/kitty_start
    [ -f "$RUTA"/scripts/settarget ] && \
        sudo install -m755 "$RUTA"/scripts/settarget /usr/local/bin/settarget && \
        info "settarget → /usr/local/bin/settarget"
    ok "prompt rounded (acento blanco) listo"
    if [ "$SHELL" != "$(command -v zsh)" ] && confirm "¿Poner zsh como shell por defecto?"; then
        chsh -s "$(command -v zsh)" && ok "shell por defecto → zsh" || warn "no se pudo cambiar el shell"
    fi
}

setup_root_prompt() {
    [ "$DO_ROOT" -eq 1 ] || return 0
    step "Configurando prompt de root (acento rojo)"
    sudo install -Dm644 "$RUTA"/zsh/p10k-mono.zsh /root/.config/p10k-mono.zsh
    sudo grep -q 'p10k-mono.zsh' /root/.zshrc 2>/dev/null || \
        echo '[[ -f ~/.config/p10k-mono.zsh ]] && source ~/.config/p10k-mono.zsh' | sudo tee -a /root/.zshrc >/dev/null
    [ -d /root/.powerlevel10k ] || sudo git clone -q --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.powerlevel10k
    ok "root usará el mismo prompt (en rojo por EUID=0)"
}

set_permissions() {
    step "Asignando permisos"
    chmod +x "$HOME"/.config/bspwm/bspwmrc        2>/dev/null
    chmod +x "$HOME"/.config/bspwm/scripts/*      2>/dev/null
    chmod +x "$HOME"/.config/polybar/launch.sh    2>/dev/null
    chmod +x "$HOME"/.config/polybar/scripts/*    2>/dev/null
    chmod +x "$HOME"/.config/bin/*.sh             2>/dev/null
    mkdir -p "$HOME/ScreenShots" "$HOME/Imágenes"
    [ -f "$RUTA"/Wallpaper/wp-pc.png ] && cp "$RUTA"/Wallpaper/wp-pc.png "$HOME/Imágenes/"
    ok "ejecutables + carpetas (~/ScreenShots, wallpaper)"
}

# ── Adaptación a hardware ──────────────────────────────────────────
CUR="$HOME/.config/polybar/current.ini"
BSPWMRC="$HOME/.config/bspwm/bspwmrc"
LAUNCH="$HOME/.config/polybar/launch.sh"
PICOM="$HOME/.config/picom/picom.conf"

# editor acotado del current.ini (lee BB_* del entorno; argv2 opcional)
_polybar_py() {
    python3 - "$CUR" "${1:-}" <<'PYEOF'
import os, sys, re
path = sys.argv[1]; extra = sys.argv[2] if len(sys.argv) > 2 else ""
lines = open(path, encoding="utf-8").read().split("\n")
def section_range(name):
    start=None
    for i,l in enumerate(lines):
        s=l.strip()
        if s=="["+name+"]": start=i; continue
        if start is not None and s.startswith("[") and s.endswith("]"): return start,i
    return (start,len(lines)) if start is not None else (None,None)
def set_key(name,key,value):
    a,b=section_range(name)
    if a is None: return
    pat=re.compile(r"^\s*"+re.escape(key)+r"\s*=")
    for i in range(a,b):
        if pat.match(lines[i]): lines[i]="{} = {}".format(key,value); return
    lines.insert(a+1,"{} = {}".format(key,value))
if os.environ.get("BB_REMOVE_BATTERY")=="1":
    a,b=section_range("bar/pill")
    if a is not None:
        for i in range(a,b):
            if lines[i].strip().startswith("modules-right"):
                k,v=lines[i].split("=",1); toks=[t for t in v.split() if t!="battery"]; out=[]
                for t in toks:
                    if t=="sep" and (not out or out[-1]=="sep"): continue
                    out.append(t)
                while out and out[-1]=="sep": out.pop()
                while out and out[0]=="sep": out.pop(0)
                lines[i]=k+"= "+" ".join(out); break
if os.environ.get("BB_BAT"): set_key("module/battery","battery",os.environ["BB_BAT"])
if os.environ.get("BB_ADP"): set_key("module/battery","adapter",os.environ["BB_ADP"])
if os.environ.get("BB_IFACE"): set_key("module/network","interface",os.environ["BB_IFACE"])
nt=os.environ.get("BB_NETTYPE")
if nt:
    set_key("module/network","interface-type",nt)
    if nt=="wired":
        set_key("module/network","label-connected",'" %local_ip%"')
        set_key("module/network","label-disconnected",'" sin red"')
    else:
        pass  # wifi: deja el label compacto (solo icono) del current.ini
if extra=="pillmonitor": set_key("bar/pill","monitor","${env:MONITOR:}")
open(path,"w",encoding="utf-8").write("\n".join(lines))
PYEOF
}

# ── Teclado (es,us · Alt+Shift) ────────────────────────────────────
# Forma robusta: regla persistente a nivel de servidor X, independiente del WM.
# Reemplaza al frágil `setxkbmap … &` del bspwmrc (que se perdía entre sesiones).
setup_keyboard() {
    [ "$DO_HARDWARE" -eq 1 ] || return 0
    step "Configurando teclado (es,us · alternar con Alt+Shift)"
    if [ -f "$RUTA/x11/00-keyboard.conf" ]; then
        sudo install -Dm644 "$RUTA"/x11/00-keyboard.conf /etc/X11/xorg.conf.d/00-keyboard.conf \
            && ok "layout persistente → /etc/X11/xorg.conf.d/00-keyboard.conf" \
            || warn "no se pudo escribir la regla X de teclado"
    else
        sudo localectl set-x11-keymap "es,us" pc105 "" "grp:alt_shift_toggle" 2>/dev/null \
            && ok "layout fijado vía localectl" || warn "no se pudo fijar el layout"
    fi
    # aplicar ya en la sesión actual, sin reiniciar X
    [ -n "${DISPLAY:-}" ] && setxkbmap -layout es,us -option grp:alt_shift_toggle 2>/dev/null \
        && info "aplicado en la sesión actual"
    return 0
}

adapt_hardware() {
    [ "$DO_HARDWARE" -eq 1 ] || return 0
    step "Adaptando al hardware"

    # Batería
    local bat adp
    bat=$(ls /sys/class/power_supply/ 2>/dev/null | grep -iE '^BAT' | head -1)
    adp=$(ls /sys/class/power_supply/ 2>/dev/null | grep -iE '^(ADP|AC)' | head -1)
    if [ -z "$bat" ]; then
        BB_REMOVE_BATTERY=1 _polybar_py; info "sin batería → módulo battery retirado"
    else
        BB_BAT="$bat" BB_ADP="${adp:-ADP0}" _polybar_py; info "batería $bat / ${adp:-ADP0}"
    fi

    # Red
    local wifi="" iface="" d n
    for d in /sys/class/net/*; do [ -d "$d/wireless" ] && wifi=$(basename "$d") && break; done
    iface="$wifi"
    if [ -z "$iface" ]; then
        iface=$(ip route 2>/dev/null | awk '/^default/{print $5; exit}')
        [ -z "$iface" ] && iface=$(ls /sys/class/net 2>/dev/null | grep -v '^lo$' | head -1)
    fi
    if [ -n "$iface" ]; then
        if [ -n "$wifi" ]; then BB_IFACE="$iface" BB_NETTYPE="wireless" _polybar_py; info "wifi $iface"
        else BB_IFACE="$iface" BB_NETTYPE="wired" _polybar_py; info "ethernet $iface"; fi
    fi

    # Touchpad
    if grep -qiE 'touchpad' /proc/bus/input/devices 2>/dev/null && [ -f "$RUTA"/x11/30-touchpad.conf ]; then
        sudo install -Dm644 "$RUTA"/x11/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf \
            && info "touchpad: 2 dedos = click derecho (reinicia X)"
    fi

    # Drivers GPU
    local gpu; gpu=$(lspci 2>/dev/null | grep -iE 'vga compatible|3d controller')
    if echo "$gpu" | grep -qi nvidia; then
        warn "GPU NVIDIA detectada"
        confirm "¿Instalar driver NVIDIA + firmware?" && sudo apt install -y nvidia-driver firmware-misc-nonfree
        if [ -f "$PICOM" ]; then grep -q '^backend' "$PICOM" && sudo sed -i 's/^backend.*/backend = "glx";/' "$PICOM" || echo 'backend = "glx";' >> "$PICOM"; fi
    elif echo "$gpu" | grep -qiE 'amd|radeon'; then
        confirm "GPU AMD: ¿instalar firmware + Mesa/Vulkan?" && sudo apt install -y firmware-amd-graphics mesa-vulkan-drivers
    elif echo "$gpu" | grep -qi intel; then
        info "GPU Intel (driver en kernel/Mesa)"
    fi

    # Monitores: elegir primario + colocar con arandr (se cierra/guarda solo) + autorandr
    if [ -n "${DISPLAY:-}" ]; then
        local mons n i; mapfile -t mons < <(xrandr --query 2>/dev/null | awk '/ connected/{print $1}')
        n=${#mons[@]}
        if [ "$n" -gt 1 ]; then
            # 1) Elegir el monitor PRIMARIO (tendrá los desktops I-V) — fácil, por número
            local primary sel res
            echo "  Monitores detectados:"
            for i in "${!mons[@]}"; do
                res=$(xrandr --query | awk -v m="${mons[i]}" '$1==m{for(j=1;j<=NF;j++) if($j ~ /[0-9]+x[0-9]+\+/){print $j; exit}}')
                printf "    %d) %-12s %s\n" "$((i+1))" "${mons[i]}" "${res:-?}"
            done
            if [ "$ASSUME_YES" -eq 1 ]; then sel=1; else
                read -rp "  → ¿Cuál es el monitor PRIMARIO? [1]: " sel; fi
            sel=${sel:-1}; primary="${mons[$((sel-1))]}"; [ -z "$primary" ] && primary="${mons[0]}"
            xrandr --output "$primary" --primary 2>/dev/null
            info "primario: $primary → desktops I-V"

            # 2) arandr para colocar arrastrando; al pulsar «Aplicar» se cierra solo y se guarda
            if [ "$ASSUME_YES" -eq 0 ] && command -v arandr >/dev/null \
               && confirm "¿Abrir arandr para colocar las pantallas arrastrando?"; then
                info "Coloca las pantallas y pulsa «Aplicar»: arandr se cerrará solo y se guardará."
                local before sig apid
                before="$(xrandr --query | grep ' connected' | sed 's/ (.*//')"
                arandr >/dev/null 2>&1 & apid=$!
                while kill -0 "$apid" 2>/dev/null; do
                    sig="$(xrandr --query | grep ' connected' | sed 's/ (.*//')"
                    [ "$sig" != "$before" ] && { sleep 1; kill "$apid" 2>/dev/null; break; }
                    sleep 1
                done
                wait "$apid" 2>/dev/null
            fi
            xrandr --output "$primary" --primary 2>/dev/null   # reasegurar primario tras arandr

            # 3) Guardar layout (autorandr lo auto-aplica al arrancar o al (des)conectar)
            if command -v autorandr >/dev/null; then
                autorandr --save default --force >/dev/null 2>&1 \
                    && info "layout guardado (autorandr «default»)" \
                    || warn "no se pudo guardar el layout con autorandr"
            else
                warn "autorandr no está instalado: el layout no se auto-aplicará"
            fi

            # 4) Repartir desktops: primario I-V, el siguiente monitor VI-X
            local secondary
            secondary=$(printf '%s\n' "${mons[@]}" | grep -vx "$primary" | head -1)
            if [ -n "$secondary" ] && grep -qE '^bspc monitor -d ' "$BSPWMRC"; then
                sed -i "s|^bspc monitor -d .*|bspc monitor \"$primary\" -d I II III IV V\nbspc monitor \"$secondary\" -d VI VII VIII IX X|" "$BSPWMRC"
                info "desktops: $primary → I-V · $secondary → VI-X"
            fi
            _polybar_py pillmonitor
        fi
    fi
    ok "hardware adaptado"
}

finish() {
    printf "\n${B}${GREEN}✓ BoladoBSPWM instalado${R}\n"
    printf "${GREY}  • Cierra sesión y entra en bspwm (o recarga: super+alt+r)\n"
    printf "  • Backups de tu config previa en ~/.config/*.bak-FECHA\n"
    printf "  • Atajos: super+Return (kitty) · super+d (rofi) · super+shift+l (lock)${R}\n\n"
    command -v notify-send >/dev/null && notify-send "BoladoBSPWM instalado" "Tema aplicado correctamente." 2>/dev/null || true
}

# ════════════════════════════════════════════════════════════════════
main() {
    banner
    preflight

    if [ "$HARDWARE_ONLY" -eq 1 ]; then
        STEPS=2; setup_keyboard; adapt_hardware; finish; return
    fi

    STEPS=10
    [ "$DO_DEPS" -eq 1 ]     || STEPS=$((STEPS-3))   # install_deps + install_fonts + install_themes
    [ "$DO_ROOT" -eq 1 ]     || STEPS=$((STEPS-1))
    [ "$DO_HARDWARE" -eq 1 ] || STEPS=$((STEPS-2))   # setup_keyboard + adapt_hardware

    if ! confirm "Instalar BoladoBSPWM en este equipo?"; then echo "Cancelado."; exit 0; fi

    [ "$DO_DEPS" -eq 1 ] && { install_deps; install_fonts; install_themes; }
    backup_configs
    copy_configs
    setup_zsh
    setup_root_prompt
    set_permissions
    setup_keyboard
    adapt_hardware
    finish
}

main "$@"
