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
DO_DEPS=1; DO_ROOT=1; DO_HARDWARE=1; ASSUME_YES=0; HARDWARE_ONLY=0; REFRESH_ONLY=0; NVIDIA_ONLY=0; DM_ONLY=0; KEYBOARD_ONLY=0

usage() {
    cat <<EOF
BoladoBSPWM v$VERSION — instalador

Uso: ./install.sh [opciones]

  -y, --yes           Modo desatendido (no pregunta)
      --no-deps       No instalar paquetes apt
      --no-root       No configurar el prompt de root
      --no-hardware   No adaptar al hardware (batería/red/monitores/drivers/touchpad)
      --hardware-only Solo re-adaptar al hardware (no copia configs ni instala)
      --refresh       Actualizar configs y recargar servicios sin reinstalar
      --nvidia        Instalar drivers NVIDIA de forma segura (headers + dkms + picom)
      --dm            Configurar display manager (GDM vs lightdm) sin reinstalar
      --keyboard      Fijar layout es,us permanente en todas las capas del sistema
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
        --refresh)       REFRESH_ONLY=1 ;;
        --nvidia)        NVIDIA_ONLY=1 ;;
        --dm)            DM_ONLY=1 ;;
        --keyboard)      KEYBOARD_ONLY=1 ;;
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
# Fija el layout en las 4 capas del sistema para que sea permanente:
#   1. /etc/default/keyboard  — TTY + udev + base del sistema
#   2. localectl               — sincroniza el subsistema systemd
#   3. xorg.conf.d             — X11 autoritativo (reinstalado DESPUÉS de localectl
#                                por si localectl lo sobreescribe con el valor incorrecto)
#   4. setxkbmap               — aplica en la sesión X actual sin reiniciar
setup_keyboard() {
    [ "$DO_HARDWARE" -eq 1 ] || return 0
    step "Configurando teclado (es,us · Alt+Shift — 4 capas)"

    # 1. /etc/default/keyboard — base del sistema (TTY, udev, localectl lo lee de aquí)
    sudo tee /etc/default/keyboard > /dev/null << 'EOF'
# BoladoBSPWM
XKBMODEL="pc105"
XKBLAYOUT="es,us"
XKBVARIANT=","
XKBOPTIONS="grp:alt_shift_toggle"
BACKSPACE="guess"
EOF
    ok "/etc/default/keyboard → es,us · grp:alt_shift_toggle"

    # 2. localectl — sincroniza systemd/udev con el keyboard subsystem
    #    NOTA: en Debian, localectl puede sobreescribir /etc/X11/xorg.conf.d/00-keyboard.conf,
    #    por eso reinstalamos nuestra copia en el paso 3.
    sudo localectl set-x11-keymap "es,us" pc105 "," "grp:alt_shift_toggle" 2>/dev/null \
        && info "localectl sincronizado → es,us" \
        || info "localectl no disponible (se usará solo xorg.conf.d)"

    # 3. /etc/X11/xorg.conf.d/00-keyboard.conf — regla X11 autoritativa
    #    Instalado DESPUÉS de localectl para asegurar que nuestros valores prevalecen.
    sudo install -Dm644 "$RUTA/x11/00-keyboard.conf" /etc/X11/xorg.conf.d/00-keyboard.conf \
        && ok "00-keyboard.conf → /etc/X11/xorg.conf.d/ (prevalece sobre localectl)" \
        || warn "no se pudo instalar 00-keyboard.conf"

    # 4. Consola (TTY) sin reiniciar
    sudo setupcon --force 2>/dev/null \
        && info "TTY: layout aplicado en consola" \
        || info "setupcon no disponible, se aplicará al reiniciar"

    # 5. IBus: forzar que siga el layout del sistema en vez de gestionar el suyo
    #    im-config inyecta GTK_IM_MODULE=ibus en cada sesión X; cuando IBus arranca
    #    (al abrir el primer app GTK) sobreescribe el layout si use-system-keyboard-layout=false.
    if command -v gsettings >/dev/null 2>&1 && \
       gsettings list-schemas 2>/dev/null | grep -q 'freedesktop.ibus'; then
        gsettings set org.freedesktop.ibus.general use-system-keyboard-layout true 2>/dev/null \
            && ok "ibus: use-system-keyboard-layout → true (ya no sobreescribirá el layout)" \
            || info "ibus: gsettings no accesible (el fix de bspwmrc lo aplica al arrancar sesión)"
    fi

    # 6. Sesión X actual (si hay DISPLAY)
    [ -n "${DISPLAY:-}" ] && setxkbmap -layout es,us -model pc105 -option grp:alt_shift_toggle 2>/dev/null \
        && info "aplicado en la sesión X actual"

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
        confirm "¿Instalar driver NVIDIA ahora (proceso completo)?" && install_nvidia
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

install_scripts() {
    step "Actualizando scripts del sistema"
    [ -f "$RUTA/scripts/kitty_start" ] && \
        sudo install -m755 "$RUTA/scripts/kitty_start" /usr/local/bin/kitty_start && \
        ok "kitty_start → /usr/local/bin/" || warn "no se pudo instalar kitty_start"
    [ -f "$RUTA/scripts/settarget" ] && \
        sudo install -m755 "$RUTA/scripts/settarget" /usr/local/bin/settarget && \
        ok "settarget → /usr/local/bin/" || warn "no se pudo instalar settarget"
}

reload_services() {
    step "Recargando servicios"
    if [ -z "${DISPLAY:-}" ]; then
        warn "Sin DISPLAY: servicios no recargados (ejecuta dentro de X)"; return
    fi

    pkill -USR1 sxhkd 2>/dev/null   && info "sxhkd recargado (USR1)"   || info "sxhkd no estaba corriendo"
    pkill -USR1 kitty 2>/dev/null   && info "kitty recargado (USR1)"   || true

    if [ -x "$HOME/.config/polybar/launch.sh" ]; then
        "$HOME/.config/polybar/launch.sh" &
        info "polybar relanzado"
    fi

    pkill picom 2>/dev/null; sleep 0.3
    picom >/dev/null 2>&1 &
    info "picom reiniciado"

    ok "servicios actualizados"
}

install_nvidia() {
    step "Instalando drivers NVIDIA (proceso seguro)"

    # 1. Asegurar non-free + non-free-firmware en sources.list
    if ! grep -q 'non-free' /etc/apt/sources.list 2>/dev/null; then
        sudo sed -i 's/^\(deb.*kali-rolling.*main\).*/\1 contrib non-free non-free-firmware/' /etc/apt/sources.list
        ok "sources.list: contrib non-free non-free-firmware habilitado"
    else
        info "sources.list: non-free ya estaba habilitado"
    fi

    # 2. Full-upgrade primero (evita conflictos de paquetes parciales)
    info "Actualizando sistema (full-upgrade)..."
    sudo apt update -q && sudo apt full-upgrade -y \
        && ok "sistema actualizado" || die "full-upgrade falló — revisa el estado de apt"

    # 3. Kernel headers ANTES del driver (DKMS los necesita para compilar el módulo)
    info "Instalando linux-headers..."
    sudo apt install -y linux-headers-amd64 linux-headers-$(uname -r) \
        && ok "headers instalados ($(uname -r))" \
        || warn "no se pudieron instalar los headers del kernel actual"

    # 4. Driver NVIDIA + firmware (el paquete blacklistea nouveau automáticamente
    #    via /etc/modprobe.d/nvidia-blacklists-nouveau.conf)
    info "Instalando nvidia-driver + firmware..."
    sudo apt install -y nvidia-driver firmware-misc-nonfree \
        && ok "nvidia-driver instalado" || die "instalación del driver falló"

    # 5. Actualizar initramfs para que el blacklist de nouveau se aplique en el boot
    info "Reconstruyendo initramfs..."
    sudo update-initramfs -u && ok "initramfs actualizado"

    # 6. Ajustar picom para NVIDIA: glx backend + vsync + xrender-sync-fence
    #    (sin estos, picom se congela con el driver propietario NVIDIA)
    if [ -f "$PICOM" ]; then
        sudo sed -i 's/^backend.*/backend = "glx";/'         "$PICOM"
        sudo sed -i 's/^vsync.*/vsync = true;/'              "$PICOM"
        sudo sed -i 's/^# xrender-sync-fence.*/xrender-sync-fence = true;/' "$PICOM"
        grep -q '^xrender-sync-fence' "$PICOM" || echo 'xrender-sync-fence = true;' | sudo tee -a "$PICOM" >/dev/null
        ok "picom: glx backend + vsync + xrender-sync-fence (requerido para NVIDIA)"
    fi

    # 7. Revertir el lanzamiento condicional de picom en bspwmrc:
    #    con driver propietario NVIDIA ya no hace falta el --vsync por línea de comandos
    if [ -f "$BSPWMRC" ]; then
        sudo sed -i \
            '/# PICOM: vsync solo/,/^fi$/c\# PICOM\npicom \&' \
            "$BSPWMRC" 2>/dev/null || true
    fi

    # 8. Activar nvidia-drm.modeset=1 en GRUB (necesario para Wayland + DRM KMS)
    if ! grep -q 'nvidia-drm.modeset=1' /etc/default/grub 2>/dev/null; then
        sudo sed -i \
            's/^\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)"/\1 nvidia-drm.modeset=1"/' \
            /etc/default/grub \
            && ok "nvidia-drm.modeset=1 → GRUB_CMDLINE_LINUX_DEFAULT" \
            || warn "no se pudo modificar /etc/default/grub"
        sudo update-grub && ok "grub.cfg regenerado" || warn "update-grub falló"
    else
        info "nvidia-drm.modeset=1 ya estaba en GRUB"
    fi

    printf "\n  ${YELLOW}!${R} ${B}Driver NVIDIA instalado — configura el display manager a continuación.${R}\n\n"

    configure_display_manager
}

_setup_lightdm() {
    # ── 1. lightdm ────────────────────────────────────────────────────
    info "Instalando lightdm..."
    sudo apt install -y lightdm \
        && ok "lightdm instalado" || die "no se pudo instalar lightdm"

    # ── 2. lightdm-mini-greeter ───────────────────────────────────────
    #    No está en repos Kali/Debian — compilar desde fuente (~1 min).
    #    Deps ligeras: solo GTK3 + liblightdm-gobject (ya presentes en el sistema).
    if [ -x /usr/bin/lightdm-mini-greeter ]; then
        ok "lightdm-mini-greeter ya estaba instalado"
    else
        info "Instalando dependencias de compilación..."
        sudo apt install -y \
            build-essential automake pkg-config \
            liblightdm-gobject-1-dev libgtk-3-dev \
            && ok "dependencias instaladas" \
            || die "no se pudieron instalar las dependencias de compilación"

        local BUILD_DIR; BUILD_DIR="$(mktemp -d /tmp/mini-greeter-XXXXX)"
        info "Clonando lightdm-mini-greeter..."
        git clone --depth 1 https://github.com/prikhi/lightdm-mini-greeter.git "$BUILD_DIR" \
            && ok "repositorio clonado" || die "no se pudo clonar lightdm-mini-greeter"

        info "Compilando (puede tardar ~1 min)..."
        (
            cd "$BUILD_DIR"
            ./autogen.sh        >/dev/null 2>&1
            ./configure --datadir /usr/share --bindir /usr/bin --sysconfdir /etc \
                        >/dev/null 2>&1
            make                >/dev/null 2>&1
        ) && sudo make -C "$BUILD_DIR" install >/dev/null 2>&1 \
            && ok "lightdm-mini-greeter compilado e instalado" \
            || die "la compilación de lightdm-mini-greeter falló"

        rm -rf "$BUILD_DIR"
    fi

    # ── 3. Wallpaper ──────────────────────────────────────────────────
    local WP_SRC="$RUTA/Wallpaper/wp-pc.png"
    local WP_DEST="/usr/share/pixmaps/bolado-bspwm.png"
    if [ -f "$WP_SRC" ]; then
        sudo install -Dm644 "$WP_SRC" "$WP_DEST" \
            && ok "wallpaper → $WP_DEST" || warn "no se pudo copiar el wallpaper"
    fi

    # ── 4. Cambiar display manager ────────────────────────────────────
    local dm_actual
    dm_actual=$(systemctl show display-manager --property=Id --value 2>/dev/null | sed 's/\.service//')
    if [ -n "$dm_actual" ] && [ "$dm_actual" != "lightdm" ]; then
        sudo systemctl disable "$dm_actual" 2>/dev/null || true
        info "$dm_actual deshabilitado"
    fi
    sudo systemctl enable lightdm \
        && ok "lightdm habilitado como display manager" || warn "no se pudo habilitar lightdm"

    # ── 5. Configs ────────────────────────────────────────────────────
    sudo install -Dm644 "$RUTA/lightdm/lightdm.conf" /etc/lightdm/lightdm.conf
    sudo install -Dm644 "$RUTA/lightdm/lightdm-mini-greeter.conf" \
                        /etc/lightdm/lightdm-mini-greeter.conf

    # Sustituir placeholder con el usuario que instaló
    sudo sed -i "s/BOLADO_USER/${USER}/" /etc/lightdm/lightdm-mini-greeter.conf \
        && ok "greeter: usuario → ${USER}"

    ok "lightdm.conf → greeter: lightdm-mini-greeter · sesión: bspwm"
    ok "tema terminal: #0d0d0d · Monospace · prompt '\$' · user@host + reloj"
}

configure_display_manager() {
    step "Configurando display manager"

    local dm_actual
    dm_actual=$(systemctl show display-manager --property=Id --value 2>/dev/null | sed 's/\.service//')
    dm_actual=${dm_actual:-"desconocido"}

    printf "\n  DM activo: ${B}${WHITE}%s${R}\n\n" "$dm_actual"
    printf "  ${B}${WHITE}1) GDM${R} — GNOME Display Manager\n"
    printf "     ${GREEN}+${R} Greeter GNOME Shell (Wayland), aspecto moderno\n"
    printf "     ${RED}–${R} Requiere nvidia-drm.modeset=1 o pantalla negra con NVIDIA\n"
    printf "     ${RED}–${R} Sin fallback X11 nativo en Kali · ~150 MB de deps GNOME\n"
    printf "\n"
    printf "  ${B}${WHITE}2) lightdm${R} ${GREEN}[recomendado para BSPWM]${R}\n"
    printf "     ${GREEN}+${R} Sin dependencias GNOME · greeter GTK minimal monocromo\n"
    printf "     ${GREEN}+${R} Siempre cae a X11 si Wayland falla · ~10 MB\n"
    printf "     ${GREEN}+${R} Tema oscuro incluido (coherente con BoladoBSPWM)\n\n"

    local choice
    if [ "$ASSUME_YES" -eq 1 ]; then
        choice=2
    else
        printf "  ${YELLOW}?${R} ¿Qué display manager usar? ${DIM}[1=gdm / 2=lightdm, default=2]${R} "
        read -r choice
    fi

    case "${choice:-2}" in
        1|gdm*) info "Manteniendo GDM — nvidia-drm.modeset=1 ya configurado, reinicia para verificar" ;;
        *)      _setup_lightdm ;;
    esac
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

    if [ "$NVIDIA_ONLY" -eq 1 ]; then
        STEPS=2; install_nvidia; return
    fi

    if [ "$DM_ONLY" -eq 1 ]; then
        STEPS=1; configure_display_manager; return
    fi

    if [ "$KEYBOARD_ONLY" -eq 1 ]; then
        DO_HARDWARE=1; STEPS=1; setup_keyboard; return
    fi

    if [ "$REFRESH_ONLY" -eq 1 ]; then
        DO_HARDWARE=1
        STEPS=5; copy_configs; set_permissions; setup_keyboard; install_scripts; reload_services; return
    fi

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
