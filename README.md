# BoladoBSPWM

Tema personal para **bspwm** en Kali Linux: monocromo + acento **ámbar**, con una
**barra de polybar única tipo pill**. Pensado para instalarse tal cual, al estilo
del instalador de AutoBspwm (S4vitar).

## Qué incluye

- **bspwm** + **sxhkd** — gestor de ventanas y atajos (volumen `wpctl`, brillo
  `brightnessctl`, multimedia `playerctl`, capturas con `flameshot`, lock `i3lock`).
- **polybar** — una sola barra `[bar/pill]` (full-width, esquinas redondeadas).
  Izquierda: power + workspaces · Centro: estado IP/HTB · Derecha: volumen %,
  wifi (ESSID + señal), batería %, reloj.
- **kitty** — paleta monocromo + ámbar vivo (`#ffb300`).
- **rofi** — tema `rofi-mono.rasi` (lanzador `super+d`).
- **Powerlevel10k** — prompt classic recoloreado vía `~/.config/p10k-mono.zsh`
  (no modifica el `.p10k.zsh` base).
- Wallpaper B&W incluido.

## Instalación

```bash
cd ~/Themes/BoladoBSPWM
./BoladoBSPWM.sh      # menú con banner
# o directamente:
./install.sh
```

El instalador:
1. Instala dependencias (`apt`).
2. Hace **backup** de tu config previa (`~/.config/<x>.bak-FECHA`).
3. Copia los configs del tema a `~/.config/`.
4. Configura zsh + Powerlevel10k (clona el motor si falta).
5. Copia el wallpaper y crea `~/ScreenShots`.
6. Asigna permisos.
7. **Adapta el tema a tu hardware** (`hardware.sh`).
8. (Opcional) pone zsh como shell por defecto.

## Adaptación a hardware (`hardware.sh`)

Se ejecuta al final del instalador (o suelto con `./hardware.sh`) y ajusta los
configs ya instalados según la máquina:

- **Batería** — detecta el nombre real (`BAT0`/`BAT1`…) y el adaptador
  (`ADP0`/`AC`…). Si es un **sobremesa sin batería**, elimina el módulo
  `battery` de la barra (y su separador) automáticamente.
- **Red** — detecta si tienes **wifi** o **ethernet** y la interfaz real
  (`wlan0`, `eth0`, `enp…`), y ajusta el módulo (ESSID+señal en wifi, IP local
  en cable).
- **Touchpad** — si hay touchpad, instala una regla libinput para que el
  **click derecho sea con 2 dedos** (y central con 3) en vez de por esquinas
  (`ClickMethod clickfinger` + tap `lrm`). Archivo: `x11/30-touchpad.conf`.
- **Monitores** — si hay **2 o más**, ofrece disposición dual personalizada
  (elegir primario/secundario y posición vía `xrandr`), reparte los escritorios
  (1-5 / 6-10) y lanza una **pill por monitor**.
- **Drivers GPU** — detecta NVIDIA / AMD / Intel y ofrece instalar el driver
  adecuado; en NVIDIA fija `backend = "glx"` en picom.

> La parte de monitores necesita una sesión X activa; córrela dentro de bspwm.
> Las de drivers/monitores son interactivas (preguntan antes de tocar nada).

No ejecutar como root. Tras instalar: cerrar sesión y entrar en bspwm, o
recargar con `super+alt+r`.

## Atajos principales

| Atajo | Acción |
|---|---|
| `super+Return` | terminal (kitty) |
| `super+d` | lanzador (rofi) |
| `super+shift+l` | bloquear (i3lock) |
| `XF86Audio*` | volumen / multimedia |
| `XF86MonBrightness*` | brillo |
| `Print` / `Ctrl+Print` / `Shift+Print` | captura región / pantalla / portapapeles |

## Paleta

`bg #141414` · `fg #f0f0f0` · acento **ámbar `#ffb300`** · wifi `#7cc043` · error `#e05561`
