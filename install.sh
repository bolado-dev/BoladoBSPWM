#!/bin/bash
#
# BoladoBSPWM · instalador del tema (monocromo + ámbar, barra pill única)
# Estilo basado en AutoBspwm (S4vitar). Instala ESTE tema tal cual.
#

if [ "$(whoami)" == "root" ]; then
    echo "[!] No ejecutes este script como root. Saliendo."
    exit 1
fi

# Ruta del repo (donde vive este script), aunque se invoque desde otro sitio
ruta="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

green="\033[1;32m"; amber="\033[1;33m"; red="\033[1;31m"; reset="\033[0m"
log()  { echo -e "${amber}[*]${reset} $1"; }
ok()   { echo -e "${green}[+]${reset} $1"; }
warn() { echo -e "${red}[!]${reset} $1"; }

# ─────────────────────────────────────────────
# 1. Dependencias (runtime del tema)
# ─────────────────────────────────────────────
log "Instalando dependencias..."
sudo apt update
sudo apt install -y \
    bspwm sxhkd polybar kitty rofi picom feh \
    flameshot brightnessctl playerctl pamixer i3lock \
    fastfetch imagemagick wmname libnotify-bin x11-utils \
    pavucontrol network-manager-gnome blueman \
    zsh zsh-syntax-highlighting zsh-autosuggestions \
    fonts-hack fonts-font-awesome \
    python3 pciutils x11-xserver-utils || warn "Algún paquete falló; revisa arriba."

# ─────────────────────────────────────────────
# 2. Backup de la config previa
# ─────────────────────────────────────────────
stamp="$(date +%Y%m%d-%H%M%S)"
for d in bspwm sxhkd polybar kitty bin; do
    if [ -e "$HOME/.config/$d" ]; then
        mv "$HOME/.config/$d" "$HOME/.config/$d.bak-$stamp"
        log "Backup: ~/.config/$d -> ~/.config/$d.bak-$stamp"
    fi
done

# ─────────────────────────────────────────────
# 3. Copiar configs del tema
# ─────────────────────────────────────────────
log "Copiando configs a ~/.config ..."
mkdir -p "$HOME/.config"
cp -r "$ruta"/Config/* "$HOME/.config/"
ok "bspwm, sxhkd, polybar, kitty y bin copiados."

# Tema de rofi (se referencia con -theme en sxhkdrc)
cp "$ruta"/rofi/rofi-mono.rasi "$HOME/.config/"
ok "Tema rofi instalado en ~/.config/rofi-mono.rasi"

# ─────────────────────────────────────────────
# 4. Zsh + Powerlevel10k (tema del prompt)
# ─────────────────────────────────────────────
[ -e "$HOME/.zshrc" ]   && cp "$HOME/.zshrc"   "$HOME/.zshrc.bak-$stamp"
[ -e "$HOME/.p10k.zsh" ] && cp "$HOME/.p10k.zsh" "$HOME/.p10k.zsh.bak-$stamp"

cp "$ruta"/zsh/.zshrc          "$HOME/.zshrc"
cp "$ruta"/zsh/.p10k.zsh       "$HOME/.p10k.zsh"
cp "$ruta"/zsh/p10k-mono.zsh   "$HOME/.config/p10k-mono.zsh"

# Asegurar que .zshrc carga el override de color monocromo+ámbar
if ! grep -q "p10k-mono.zsh" "$HOME/.zshrc"; then
    echo '[[ -f ~/.config/p10k-mono.zsh ]] && source ~/.config/p10k-mono.zsh' >> "$HOME/.zshrc"
fi

# Motor de Powerlevel10k
if [ ! -d "$HOME/.powerlevel10k" ]; then
    log "Clonando Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.powerlevel10k"
fi
ok "Prompt p10k (monocromo + blanco) configurado."

# Prompt de ROOT: mismo override (se vuelve rojo solo por el EUID==0 interno)
log "Configurando prompt de root..."
sudo install -Dm644 "$ruta"/zsh/p10k-mono.zsh /root/.config/p10k-mono.zsh
sudo grep -q 'p10k-mono.zsh' /root/.zshrc 2>/dev/null || \
    echo '[[ -f ~/.config/p10k-mono.zsh ]] && source ~/.config/p10k-mono.zsh' | sudo tee -a /root/.zshrc >/dev/null
[ -d /root/.powerlevel10k ] || sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.powerlevel10k
ok "Prompt de root configurado (acento rojo)."

# kitty_start (fastfetch + zsh) usado por kitty como shell
if [ -f "$ruta"/scripts/kitty_start ]; then
    sudo cp "$ruta"/scripts/kitty_start /usr/local/bin/ && sudo chmod +x /usr/local/bin/kitty_start
fi

# ─────────────────────────────────────────────
# 5. Wallpaper + carpetas
# ─────────────────────────────────────────────
mkdir -p "$HOME/Imágenes" "$HOME/ScreenShots"
cp "$ruta"/Wallpaper/wp-pc.png "$HOME/Imágenes/" 2>/dev/null && ok "Wallpaper copiado a ~/Imágenes/wp-pc.png"

# ─────────────────────────────────────────────
# 6. Permisos de ejecución
# ─────────────────────────────────────────────
chmod +x "$HOME"/.config/bspwm/bspwmrc 2>/dev/null
chmod +x "$HOME"/.config/bspwm/scripts/* 2>/dev/null
chmod +x "$HOME"/.config/polybar/launch.sh 2>/dev/null
chmod +x "$HOME"/.config/polybar/scripts/* 2>/dev/null
chmod +x "$HOME"/.config/bin/*.sh 2>/dev/null
ok "Permisos asignados."

# ─────────────────────────────────────────────
# 6.5 Adaptación al hardware (batería, red, monitores, drivers)
# ─────────────────────────────────────────────
if [ -f "$ruta"/hardware.sh ]; then
    log "Adaptando el tema a tu hardware..."
    bash "$ruta"/hardware.sh
fi

# ─────────────────────────────────────────────
# 7. Shell por defecto a zsh (opcional)
# ─────────────────────────────────────────────
if [ "$SHELL" != "$(command -v zsh)" ]; then
    log "Cambiando shell por defecto a zsh (pedirá tu contraseña)..."
    chsh -s "$(command -v zsh)" || warn "No se pudo cambiar el shell; hazlo manual con: chsh -s \$(which zsh)"
fi

echo
ok "BoladoBSPWM instalado."
echo -e "${amber}Cierra sesión y entra en bspwm, o recarga con: super+alt+r${reset}"
command -v notify-send >/dev/null && notify-send "BoladoBSPWM instalado 🎨" "Tema monocromo + ámbar listo."
