#!/usr/bin/env bash
# Manual flotante de atajos — Alt + F1
# Abre una ventana kitty centrada con less; cierra con q

B=$'\e[1m'
R=$'\e[0m'
D=$'\e[2m'
W=$'\e[97m'
G=$'\e[90m'
K=$'\e[1;93m'   # tecla (amarillo negrita)
S=$'\e[1;37m'   # sección (blanco negrita)
AR=$'\e[90m→\e[0m'

tmp=$(mktemp)

cat > "$tmp" << EOF
${B}${W}
  BoladoBSPWM — Atajos de teclado${R}
${D}${W}  ════════════════════════════════════════════════════════════════${R}

${S}  APLICACIONES${R}
${G}  ──────────────────────────────────────────────────────────────${R}
  ${K}Super + Return${R}              $AR  Terminal (kitty)
  ${K}Super + D${R}                   $AR  Lanzador (rofi)
  ${K}Super + Shift + L${R}           $AR  Bloquear pantalla (i3lock)
  ${K}Super + Shift + F${R}           $AR  Firefox
  ${K}Super + Shift + B${R}           $AR  BurpSuite
  ${K}Alt + F1${R}                    $AR  Este manual

${S}  GESTIÓN DE VENTANAS${R}
${G}  ──────────────────────────────────────────────────────────────${R}
  ${K}Super + W${R}                   $AR  Cerrar ventana
  ${K}Super + Shift + W${R}           $AR  Matar ventana
  ${K}Super + M${R}                   $AR  Alternar tiled / monocle
  ${K}Super + G${R}                   $AR  Swap con la ventana más grande
  ${K}Super + Y${R}                   $AR  Mover nodo marcado al preseleccionado
  ${K}Super + Alt + R${R}             $AR  Reiniciar bspwm
  ${K}Super + Alt + Q${R}             $AR  Salir de bspwm
  ${K}Super + Escape${R}              $AR  Recargar sxhkd

${S}  ESTADO DE VENTANAS${R}
${G}  ──────────────────────────────────────────────────────────────${R}
  ${K}Super + T${R}                   $AR  Tiled
  ${K}Super + Shift + T${R}           $AR  Pseudo-tiled
  ${K}Super + S${R}                   $AR  Flotante
  ${K}Super + F${R}                   $AR  Pantalla completa

${S}  FLAGS DE NODO${R}
${G}  ──────────────────────────────────────────────────────────────${R}
  ${K}Super + Ctrl + M${R}            $AR  Marked
  ${K}Super + Ctrl + X${R}            $AR  Locked
  ${K}Super + Ctrl + Y${R}            $AR  Sticky
  ${K}Super + Ctrl + Z${R}            $AR  Private

${S}  FOCO Y SWAP${R}
${G}  ──────────────────────────────────────────────────────────────${R}
  ${K}Super + ← ↓ ↑ →${R}            $AR  Mover foco entre ventanas
  ${K}Super + Shift + ← ↓ ↑ →${R}    $AR  Intercambiar ventana en esa dirección
  ${K}Super + C${R}                   $AR  Siguiente ventana del escritorio
  ${K}Super + Shift + C${R}           $AR  Ventana anterior del escritorio
  ${K}Super + \`${R}                   $AR  Último nodo activo
  ${K}Super + Tab${R}                 $AR  Último escritorio activo
  ${K}Super + O / I${R}               $AR  Historial de foco (anterior / siguiente)

${S}  ESCRITORIOS${R}
${G}  ──────────────────────────────────────────────────────────────${R}
  ${K}Super + 1–9, 0${R}              $AR  Ir al escritorio I–X
  ${K}Super + Shift + 1–9, 0${R}      $AR  Mover ventana al escritorio I–X
  ${K}Super + [${R}                   $AR  Escritorio anterior
  ${K}Super + ]${R}                   $AR  Escritorio siguiente

${S}  PRESELECCIÓN DE SPLITS${R}
${G}  ──────────────────────────────────────────────────────────────${R}
  ${K}Super + Ctrl + Alt + ← ↓ ↑ →${R}  $AR  Preseleccionar dirección
  ${K}Super + Ctrl + 1–9${R}          $AR  Preseleccionar ratio (0.1–0.9)
  ${K}Super + Ctrl + Space${R}        $AR  Cancelar preselección del nodo
  ${K}Super + Ctrl + Alt + Space${R}  $AR  Cancelar preselección del escritorio

${S}  REDIMENSIONAR Y MOVER${R}
${G}  ──────────────────────────────────────────────────────────────${R}
  ${K}Super + Alt + ← ↓ ↑ →${R}      $AR  Redimensionar ventana
  ${K}Super + Ctrl + ← ↓ ↑ →${R}     $AR  Mover ventana flotante

${S}  CAPTURAS DE PANTALLA${R}
${G}  ──────────────────────────────────────────────────────────────${R}
  ${K}Print${R}                       $AR  Captura región interactiva → ~/ScreenShots
  ${K}Ctrl + Print${R}                $AR  Pantalla completa → ~/ScreenShots
  ${K}Shift + Print${R}               $AR  Pantalla completa → portapapeles

${S}  VOLUMEN  (wpctl / PipeWire)${R}
${G}  ──────────────────────────────────────────────────────────────${R}
  ${K}Vol+${R}                        $AR  Subir volumen 5%
  ${K}Vol-${R}                        $AR  Bajar volumen 5%
  ${K}Mute${R}                        $AR  Silenciar / activar audio
  ${K}MicMute${R}                     $AR  Silenciar / activar micrófono

${S}  BRILLO  (brightnessctl)${R}
${G}  ──────────────────────────────────────────────────────────────${R}
  ${K}Brillo+${R}                     $AR  +5% brillo
  ${K}Brillo-${R}                     $AR  -5% brillo

${S}  MULTIMEDIA  (playerctl)${R}
${G}  ──────────────────────────────────────────────────────────────${R}
  ${K}Play / Pause${R}                $AR  Reproducir / pausar
  ${K}Next / Prev${R}                 $AR  Siguiente / anterior pista
  ${K}Stop${R}                        $AR  Detener reproducción

${S}  TERMINAL · SPLITS  (kitty)${R}
${G}  ──────────────────────────────────────────────────────────────${R}
  ${K}Ctrl + Shift + \${R}            $AR  Dividir en vertical (panel derecho)
  ${K}Ctrl + Shift + -${R}            $AR  Dividir en horizontal (panel inferior)
  ${K}Ctrl + ← ↓ ↑ →${R}             $AR  Navegar entre paneles
  ${K}Ctrl + Shift + W${R}            $AR  Cerrar panel
  ${K}Ctrl + Shift + Z${R}            $AR  Zoom / alternar panel a pantalla completa
  ${K}Ctrl + Shift + Enter${R}        $AR  Nuevo panel (layout actual)

${S}  TERMINAL · TABS  (kitty)${R}
${G}  ──────────────────────────────────────────────────────────────${R}
  ${K}Ctrl + Shift + T${R}            $AR  Nueva tab (en el directorio actual)
  ${K}Ctrl + Shift + →${R}            $AR  Tab siguiente
  ${K}Ctrl + Shift + ←${R}            $AR  Tab anterior
  ${K}Ctrl + Shift + Q${R}            $AR  Cerrar tab
  ${K}Ctrl + Alt + T${R}              $AR  Renombrar tab
  ${K}Ctrl + Shift + .${R}            $AR  Mover tab a la derecha
  ${K}Ctrl + Shift + ,${R}            $AR  Mover tab a la izquierda

${D}${W}  ════════════════════════════════════════════════════════════════${R}
${G}  q / Esc para cerrar${R}

EOF

TMP_KEYS="$tmp" kitty \
    --class float-help \
    --title "Atajos · BoladoBSPWM" \
    --override font_size=11.0 \
    --override initial_window_width=760 \
    --override initial_window_height=700 \
    sh -c 'less -R "$TMP_KEYS"; rm -f "$TMP_KEYS"'
