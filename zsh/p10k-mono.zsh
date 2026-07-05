# Overrides de color/forma para Powerlevel10k: HACKER minimalista.
# Monocromo (negro/blanco/grises) + acento ÁMBAR + rojo de aviso.
# Se carga DESPUÉS de ~/.p10k.zsh desde ~/.zshrc, así no hay que tocar
# el .p10k.zsh (propiedad de root). Para revertir: borra el `source` en .zshrc.
#
# Estilo: BLOQUE LIMPIO de una sola línea (sin marco ┌ └─),
# icono de carpeta + ruta + git en línea, prompt char ❯ al final.
# Paleta (xterm-256): ámbar 214/215, grises 234/240/242/245/250, rojo 196.

# ─────────────────────────────────────────────
#  Estructura mínima (afilada y compacta)
# ─────────────────────────────────────────────

# Todo en una línea: os · dir · git · prompt_char. Estado/tiempo a la derecha.
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon dir vcs prompt_char)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time time)

# Una línea en blanco arriba: bloque que respira, limpio.
typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

# ─────────────────────────────────────────────
#  PLANO: sin fondos de burbuja, sin separadores redondeados
# ─────────────────────────────────────────────

# Fondo transparente en todos los segmentos (look "lean")
typeset -g POWERLEVEL9K_BACKGROUND=
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_MIDDLE_WHITESPACE=' '
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=' '
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_PROMPT_FIRST_SEGMENT_START_SYMBOL=
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_PROMPT_LAST_SEGMENT_END_SYMBOL=

# ─────────────────────────────────────────────
#  UNA sola línea: sin marco ┌ └─ (bloque limpio)
# ─────────────────────────────────────────────
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=
typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX=
typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX=
typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX=
typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX=

# ─────────────────────────────────────────────
#  OS icon: logo Bolado, plano y neutro
# ─────────────────────────────────────────────
typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=250
typeset -g POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION=$''   # logo Bolado (U+E800)

# ─────────────────────────────────────────────
#  Directorio: monocromo (blanco/gris), icono de carpeta + ruta
# ─────────────────────────────────────────────
typeset -g POWERLEVEL9K_DIR_FOREGROUND=252
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=242
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=231
typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_CONTENT_EXPANSION='%244F%f ${P9K_CONTENT}'

# ─────────────────────────────────────────────
#  Git/VCS: icono de rama + nombre, sin paréntesis; modificados en blanco
# ─────────────────────────────────────────────
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=245
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=245
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=231
typeset -g POWERLEVEL9K_VCS_BRANCH_ICON='%244F%f '
typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${P9K_CONTENT}'

# ─────────────────────────────────────────────
#  Estado / tiempo a la derecha: grises discretos
# ─────────────────────────────────────────────
typeset -g POWERLEVEL9K_STATUS_OK=false                       # no mostrar OK (silencio)
typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=196
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=242
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=2
typeset -g POWERLEVEL9K_TIME_FOREGROUND=240
typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'

# ─────────────────────────────────────────────
#  Prompt char ❯ : blanco al ir bien, rojo al fallar
# ─────────────────────────────────────────────
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=231
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION='❯'
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION='❯'

# ─────────────────────────────────────────────
#  ROOT: mismo estilo afilado pero con acento ROJO (aviso)
#  (este mismo archivo se sourcea también desde /root)
# ─────────────────────────────────────────────
if [[ $EUID -eq 0 ]]; then
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=203                                          # logo rojo claro
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=203                                              # ruta en rojo
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=231
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196          # prompt char rojo
fi
