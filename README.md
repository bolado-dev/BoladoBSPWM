<div align="center">

# BoladoBSPWM

**Un *rice* monocromo para bspwm, pensado para Kali Linux.**

Minimalista, con una única barra de polybar tipo *pill* y un instalador que se adapta
solo al hardware de cada máquina.

<br>

![bspwm](https://img.shields.io/badge/WM-bspwm-2b2b2b?style=flat-square)
![polybar](https://img.shields.io/badge/bar-polybar-2b2b2b?style=flat-square)
![kitty](https://img.shields.io/badge/terminal-kitty-2b2b2b?style=flat-square)
![rofi](https://img.shields.io/badge/launcher-rofi-2b2b2b?style=flat-square)
![zsh](https://img.shields.io/badge/shell-zsh%20%2B%20p10k-2b2b2b?style=flat-square)
![Kali](https://img.shields.io/badge/Kali%20Linux-557C94?style=flat-square&logo=kalilinux&logoColor=white)

<br>

<img src="Wallpaper/wp-pc.png" alt="BoladoBSPWM" width="760">

</div>

---

## Sobre el proyecto

Configuración personal de escritorio para `bspwm`. La estética es **monocroma** —negros y
blancos— con una **barra de polybar única tipo pill**: full-width y de esquinas redondeadas.

Todo está pensado para instalarse tal cual mediante un solo script que, además, **detecta y se
adapta al hardware** de cada equipo: batería, red, touchpad, monitores y drivers de GPU.

## Componentes

| Pieza | Detalle |
|---|---|
| **bspwm + sxhkd** | Gestor de ventanas y atajos: volumen (`wpctl`), brillo (`brightnessctl`), multimedia (`playerctl`), capturas (`flameshot`), bloqueo (`i3lock`). |
| **polybar** | Una sola barra `[bar/pill]`. Izquierda: power, workspaces y reproductor · Centro: estado IP / HTB · Derecha: volumen, wifi (ESSID y señal), batería y reloj. |
| **kitty** | Paleta monocroma. |
| **rofi** | Tema `rofi-mono.rasi`, lanzador con `super + d`. |
| **Powerlevel10k** | Prompt *classic* recoloreado vía `~/.config/p10k-mono.zsh` (no toca tu `.p10k.zsh` base). |
| **fastfetch** | Banner ASCII al abrir la terminal. |
| **picom** | Blur `dual_kawase` ligero en barra y terminal. |
| **HTB** | `settarget` escribe el objetivo en `/etc/hosts` y la barra lo muestra. |

## Instalación

Un único script lo hace todo:

```bash
git clone https://github.com/bolado-dev/BoladoBSPWM.git ~/Themes/BoladoBSPWM
cd ~/Themes/BoladoBSPWM
./install.sh
```

> [!WARNING]
> No lo ejecutes como root. Tras instalar, cierra sesión y entra en bspwm, o recarga con `super + alt + r`.

<details>
<summary><b>Opciones del instalador</b></summary>

<br>

```text
-y, --yes           Modo desatendido (no pregunta)
    --no-deps       No instalar paquetes apt
    --no-root       No configurar el prompt de root
    --no-hardware   No adaptar al hardware
    --hardware-only Solo re-adaptar al hardware (no copia configs)
-h, --help          Ayuda
```

</details>

<details>
<summary><b>Fases del instalador</b></summary>

<br>

1. Dependencias (`apt`).
2. Backup de tu configuración previa (`~/.config/<x>.bak-FECHA`).
3. Copia los configs del tema a `~/.config/`.
4. Configura zsh y Powerlevel10k (clona el motor si falta).
5. Configura el prompt de root (mismo estilo, acento rojo).
6. Permisos, wallpaper y `~/ScreenShots`.
7. Adapta al hardware (batería, red, touchpad, monitores, drivers).
8. Opcionalmente, pone zsh como shell por defecto.

</details>

## Adaptación al hardware

Integrada en el instalador, o re-ejecutable con `./install.sh --hardware-only`. Ajusta los
configs según la máquina:

| Componente | Qué hace |
|---|---|
| **Batería** | Detecta `BAT0`/`BAT1` y el adaptador; si es un sobremesa sin batería, elimina el módulo automáticamente. |
| **Red** | Detecta wifi o ethernet y la interfaz real (`wlan0`, `eth0`, `enp…`) y ajusta el módulo. |
| **Touchpad** | Regla libinput: click derecho con dos dedos, central con tres (`clickfinger` + tap `lrm`). |
| **Monitores** | Con dos o más, ofrece disposición dual (`xrandr`), reparte escritorios y lanza una pill por monitor. |
| **Drivers GPU** | Detecta NVIDIA / AMD / Intel y ofrece instalar el driver; en NVIDIA fija `backend = "glx"` en picom. |

> [!NOTE]
> La parte de monitores necesita una sesión X activa; córrela dentro de bspwm. Drivers y
> monitores son interactivos: preguntan antes de tocar nada.

## Atajos principales

| Atajo | Acción |
|---|---|
| `super + Return` | Terminal (kitty) |
| `super + d` | Lanzador (rofi) |
| `super + shift + l` | Bloquear (i3lock) |
| `super + w` · `super + shift + w` | Cerrar · matar ventana |
| `super + {t,s,f}` | Tiled · floating · fullscreen |
| `super + {flechas}` | Mover el foco entre ventanas |
| `super + alt + r` | Recargar bspwm |
| `XF86Audio*` | Volumen y multimedia |
| `XF86MonBrightness*` | Brillo |
| `Print` · `Ctrl+Print` · `Shift+Print` | Captura región · pantalla · portapapeles |

## Paleta

| Rol | Token | Hex |
|---|---|---|
| Fondo | `bg` | `#141414` |
| Texto | `fg` | `#f0f0f0` |
| Wifi | `green` | `#7cc043` |
| Error | `red` | `#e05561` |

---

<div align="center">

Por [**bolado-dev**](https://github.com/bolado-dev) · inspirado en el flujo de instalación de los entornos de S4vitar.

</div>
