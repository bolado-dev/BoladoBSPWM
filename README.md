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
| **polybar** | Una sola barra `[bar/pill]`. Izquierda: logo + workspaces · Centro: estado IP / HTB · Derecha: volumen, wifi (ESSID y señal), batería, reloj y power. |
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

## Atajos de teclado

> Pulsa `Alt + F1` en el escritorio para abrir el manual flotante completo.

### Aplicaciones

| Atajo | Acción |
|---|---|
| `Super + Return` | Terminal (kitty) |
| `Super + D` | Lanzador (rofi) |
| `Super + Shift + L` | Bloquear pantalla (i3lock) |
| `Super + Shift + F` | Firefox |
| `Super + Shift + B` | BurpSuite |
| `Alt + F1` | Manual de atajos (flotante) |

### Gestión de ventanas (bspwm)

| Atajo | Acción |
|---|---|
| `Super + W` | Cerrar ventana |
| `Super + Shift + W` | Matar ventana |
| `Super + M` | Alternar tiled / monocle |
| `Super + G` | Swap con la ventana más grande |
| `Super + Y` | Mover nodo marcado al preseleccionado |
| `Super + Alt + R` | Reiniciar bspwm |
| `Super + Alt + Q` | Salir de bspwm |
| `Super + Escape` | Recargar sxhkd |

### Estado de ventanas

| Atajo | Acción |
|---|---|
| `Super + T` | Tiled |
| `Super + Shift + T` | Pseudo-tiled |
| `Super + S` | Flotante |
| `Super + F` | Pantalla completa |

### Flags de nodo

| Atajo | Acción |
|---|---|
| `Super + Ctrl + M` | Marked |
| `Super + Ctrl + X` | Locked |
| `Super + Ctrl + Y` | Sticky |
| `Super + Ctrl + Z` | Private |

### Foco y swap

| Atajo | Acción |
|---|---|
| `Super + ←↓↑→` | Mover foco entre ventanas |
| `Super + Shift + ←↓↑→` | Intercambiar ventana en esa dirección |
| `Super + C` | Siguiente ventana del escritorio |
| `Super + Shift + C` | Ventana anterior del escritorio |
| ``Super + ` `` | Último nodo activo |
| `Super + Tab` | Último escritorio activo |
| `Super + O / I` | Historial de foco (anterior / siguiente) |

### Escritorios

| Atajo | Acción |
|---|---|
| `Super + 1–9, 0` | Ir al escritorio I–X |
| `Super + Shift + 1–9, 0` | Mover ventana al escritorio I–X |
| `Super + [` | Escritorio anterior |
| `Super + ]` | Escritorio siguiente |

### Preselección de splits

| Atajo | Acción |
|---|---|
| `Super + Ctrl + Alt + ←↓↑→` | Preseleccionar dirección |
| `Super + Ctrl + 1–9` | Preseleccionar ratio (0.1–0.9) |
| `Super + Ctrl + Space` | Cancelar preselección del nodo |
| `Super + Ctrl + Alt + Space` | Cancelar preselección del escritorio |

### Redimensionar y mover

| Atajo | Acción |
|---|---|
| `Super + Alt + ←↓↑→` | Redimensionar ventana |
| `Super + Ctrl + ←↓↑→` | Mover ventana flotante |

### Capturas de pantalla

| Atajo | Acción |
|---|---|
| `Print` | Captura región interactiva → `~/ScreenShots` |
| `Ctrl + Print` | Pantalla completa → `~/ScreenShots` |
| `Shift + Print` | Pantalla completa → portapapeles |

### Multimedia y sistema

| Atajo | Acción |
|---|---|
| `Vol+ / Vol-` | Volumen +5% / -5% (wpctl) |
| `Mute` | Silenciar / activar audio |
| `MicMute` | Silenciar / activar micrófono |
| `Brillo+ / Brillo-` | Brillo +5% / -5% (brightnessctl) |
| `Play/Pause` | Reproducir / pausar (playerctl) |
| `Next / Prev` | Siguiente / anterior pista |
| `Stop` | Detener reproducción |

### Terminal — Splits (kitty)

| Atajo | Acción |
|---|---|
| `Ctrl + Shift + \` | Dividir en vertical (panel derecho) |
| `Ctrl + Shift + -` | Dividir en horizontal (panel inferior) |
| `Ctrl + ←↓↑→` | Navegar entre paneles |
| `Ctrl + Shift + W` | Cerrar panel |
| `Ctrl + Shift + Z` | Zoom / alternar panel a pantalla completa |
| `Ctrl + Shift + Enter` | Nuevo panel en el layout actual |

### Terminal — Tabs (kitty)

| Atajo | Acción |
|---|---|
| `Ctrl + Shift + T` | Nueva tab (directorio actual) |
| `Ctrl + Shift + →` | Tab siguiente |
| `Ctrl + Shift + ←` | Tab anterior |
| `Ctrl + Shift + Q` | Cerrar tab |
| `Ctrl + Alt + T` | Renombrar tab |
| `Ctrl + Shift + .` | Mover tab a la derecha |
| `Ctrl + Shift + ,` | Mover tab a la izquierda |

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
