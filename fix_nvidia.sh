#!/usr/bin/env bash
#
#  ╭───────────────────────────────────────────────────────────────╮
#  │  BoladoBSPWM — fix_nvidia.sh                                   │
#  │  Arregla pantalla negra tras instalar drivers NVIDIA           │
#  │  Causa: GDM falla (Wayland sin modeset + unit X11 ausente)     │
#  │  Solución: nvidia-drm.modeset=1 + elección de DM              │
#  ╰───────────────────────────────────────────────────────────────╯
#
#  Uso: ./fix_nvidia.sh [-y]

set -uo pipefail

ASSUME_YES=0
RUTA="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ "${1:-}" == "-y" || "${1:-}" == "--yes" ]] && ASSUME_YES=1

# ── Estilo / logging ───────────────────────────────────────────────
if [ -t 1 ]; then
    B=$'\e[1m'; DIM=$'\e[2m'; R=$'\e[0m'
    WHITE=$'\e[97m'; GREY=$'\e[90m'; GREEN=$'\e[32m'; YELLOW=$'\e[33m'; RED=$'\e[31m'
else
    B=""; DIM=""; R=""; WHITE=""; GREY=""; GREEN=""; YELLOW=""; RED=""
fi

STEP=0; STEPS=3
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

# ── Pre-flight ─────────────────────────────────────────────────────
[ "$(id -u)" -eq 0 ] && die "No ejecutes el script como root (usa tu usuario; pedirá sudo cuando haga falta)."
command -v apt   >/dev/null || die "Requiere Debian/Kali (apt no encontrado)."
command -v sudo  >/dev/null || die "Se necesita sudo."
command -v nvidia-smi >/dev/null 2>&1 || die "nvidia-smi no encontrado. Instala primero los drivers con: ./install.sh --nvidia"

# ── Info inicial ───────────────────────────────────────────────────
printf "\n${B}${WHITE}BoladoBSPWM — fix_nvidia.sh${R}\n"
printf "${GREY}  Arregla pantalla negra causada por GDM + driver NVIDIA${R}\n\n"
printf "  ${GREY}Driver:${R}    $(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null || echo '?')\n"
printf "  ${GREY}GPU:${R}       $(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null || echo '?')\n"
printf "  ${GREY}DM activo:${R} $(systemctl show display-manager --property=Id --value 2>/dev/null | sed 's/\.service//' || echo '?')\n\n"

confirm "¿Aplicar la corrección ahora?" || { info "Cancelado."; exit 0; }

# ════════════════════════════════════════════════════════════════════
#  Paso 1 — nvidia-drm.modeset=1 en GRUB
# ════════════════════════════════════════════════════════════════════
step "Habilitando nvidia-drm.modeset=1 en GRUB"

if grep -q 'nvidia-drm.modeset=1' /etc/default/grub 2>/dev/null; then
    ok "nvidia-drm.modeset=1 ya estaba en GRUB"
else
    sudo sed -i \
        's/^\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)"/\1 nvidia-drm.modeset=1"/' \
        /etc/default/grub \
        && ok "nvidia-drm.modeset=1 → GRUB_CMDLINE_LINUX_DEFAULT" \
        || die "no se pudo modificar /etc/default/grub"
    info "Regenerando grub.cfg..."
    sudo update-grub && ok "grub.cfg actualizado" || die "update-grub falló"
fi

# ════════════════════════════════════════════════════════════════════
#  Paso 2 — Reconstruir initramfs
# ════════════════════════════════════════════════════════════════════
step "Reconstruyendo initramfs"
info "Ejecutando update-initramfs -u (puede tardar ~30s)..."
sudo update-initramfs -u \
    && ok "initramfs actualizado" \
    || warn "update-initramfs terminó con error (puede no ser crítico)"

# ════════════════════════════════════════════════════════════════════
#  Paso 3 — Display manager
# ════════════════════════════════════════════════════════════════════
step "Configurando display manager"

dm_actual=$(systemctl show display-manager --property=Id --value 2>/dev/null | sed 's/\.service//')
dm_actual=${dm_actual:-"desconocido"}

printf "\n  DM activo: ${B}${WHITE}%s${R}\n\n" "$dm_actual"
printf "  ${B}${WHITE}1) GDM${R} — GNOME Display Manager\n"
printf "     ${GREEN}+${R} Greeter GNOME Shell (Wayland), aspecto moderno\n"
printf "     ${RED}–${R} Requiere nvidia-drm.modeset=1 o pantalla negra con NVIDIA\n"
printf "     ${RED}–${R} Sin fallback X11 nativo en Kali · ~150 MB de deps GNOME\n"
printf "\n"
printf "  ${B}${WHITE}2) lightdm${R} + ${B}web-greeter${R} + tema ${B}Glorious${R} ${GREEN}[recomendado para BSPWM]${R}\n"
printf "     ${GREEN}+${R} Greeter webkit2 moderno · tema Glorious con tu wallpaper\n"
printf "     ${GREEN}+${R} Siempre cae a X11 si Wayland falla · sin deps GNOME\n\n"

if [ "$ASSUME_YES" -eq 1 ]; then
    dm_choice=2
else
    printf "  ${YELLOW}?${R} ¿Qué display manager usar? ${DIM}[1=gdm / 2=lightdm+Glorious, default=2]${R} "
    read -r dm_choice
fi

case "${dm_choice:-2}" in
    1|gdm*)
        info "Manteniendo GDM — con modeset=1 activo debería arrancar correctamente"
        ;;
    *)
        # ── lightdm ───────────────────────────────────────────────────
        dpkg -l lightdm 2>/dev/null | grep -q '^ii' || {
            info "Instalando lightdm..."
            sudo apt install -y lightdm && ok "lightdm instalado" || die "no se pudo instalar lightdm"
        }

        # ── web-greeter ───────────────────────────────────────────────
        if ! dpkg -l web-greeter 2>/dev/null | grep -q '^ii'; then
            if apt-cache show web-greeter >/dev/null 2>&1; then
                sudo apt install -y web-greeter && ok "web-greeter instalado (apt)"
            else
                local WG_VER="4.0.0"
                local WG_URL="https://github.com/JezerM/web-greeter/releases/download/${WG_VER}/web-greeter-${WG_VER}-debian.deb"
                info "Descargando web-greeter (~143 MB)..."
                wget -q --show-progress -O /tmp/web-greeter.deb "$WG_URL" \
                    && ok "web-greeter descargado" || die "no se pudo descargar web-greeter"
                sudo dpkg -i /tmp/web-greeter.deb || sudo apt install -f -y
                ok "web-greeter instalado"
                rm -f /tmp/web-greeter.deb
            fi
        else
            ok "web-greeter ya estaba instalado"
        fi

        # ── Tema Glorious ─────────────────────────────────────────────
        THEME_DIR="/usr/share/lightdm-webkit/themes/glorious"
        if [ -d "$THEME_DIR/.git" ]; then
            sudo git -C "$THEME_DIR" pull --ff-only -q \
                && ok "Glorious actualizado" || warn "Glorious: usando copia existente"
        else
            info "Clonando tema Glorious..."
            sudo git clone --depth 1 \
                https://github.com/eromatiya/lightdm-webkit2-theme-glorious.git \
                "$THEME_DIR" \
                && ok "Glorious → $THEME_DIR" || die "no se pudo clonar el tema Glorious"
        fi

        # ── Wallpaper ─────────────────────────────────────────────────
        [ -f "$RUTA/Wallpaper/wp-pc.png" ] && \
            sudo install -Dm644 "$RUTA/Wallpaper/wp-pc.png" /usr/share/backgrounds/bolado-bspwm.png \
            && ok "wallpaper → /usr/share/backgrounds/bolado-bspwm.png"

        # ── Cambiar DM ────────────────────────────────────────────────
        [ -n "$dm_actual" ] && [ "$dm_actual" != "lightdm" ] && \
            sudo systemctl disable "$dm_actual" 2>/dev/null && info "$dm_actual deshabilitado"
        sudo systemctl enable lightdm \
            && ok "lightdm habilitado" || warn "no se pudo habilitar lightdm"

        # ── Configs ───────────────────────────────────────────────────
        if [ -f "$RUTA/lightdm/lightdm.conf" ]; then
            sudo install -Dm644 "$RUTA/lightdm/lightdm.conf"     /etc/lightdm/lightdm.conf
            sudo install -Dm644 "$RUTA/lightdm/web-greeter.conf" /etc/lightdm/web-greeter.conf
            ok "lightdm.conf + web-greeter.conf instalados"
        else
            # Fallback si no existe el repo completo
            sudo tee /etc/lightdm/lightdm.conf > /dev/null << 'LCONF'
# BoladoBSPWM
[Seat:*]
greeter-session=web-greeter
user-session=bspwm
LCONF
            sudo tee /etc/lightdm/web-greeter.conf > /dev/null << 'GCONF'
# BoladoBSPWM
[greeter]
debug-mode          = false
screensaver-timeout = 300
webkit-theme        = glorious

[branding]
background-images   = /usr/share/backgrounds
GCONF
            ok "lightdm.conf + web-greeter.conf escritos (fallback)"
        fi
        ;;
esac

# ── Resumen ────────────────────────────────────────────────────────
printf "\n${B}${GREEN}✓ Corrección aplicada${R}\n"
printf "${GREY}"
printf "  • nvidia-drm.modeset=1 activo al próximo boot\n"
printf "  • initramfs reconstruido\n"
case "${dm_choice:-2}" in
    1|gdm*) printf "  • GDM mantenido (verifica con: systemctl status gdm)\n" ;;
    *)      printf "  • lightdm + web-greeter + tema Glorious con wallpaper de BoladoBSPWM\n" ;;
esac
printf "${R}\n"
printf "  ${YELLOW}!${R} ${B}Necesitas reiniciar para aplicar los cambios.${R}\n\n"

confirm "¿Reiniciar ahora?" && sudo reboot || printf "  ${GREY}· Reinicia cuando quieras: sudo reboot${R}\n\n"
