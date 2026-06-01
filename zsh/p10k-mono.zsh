# Overrides de color para Powerlevel10k: monocromo + acento ámbar.
# Se carga DESPUÉS de ~/.p10k.zsh desde ~/.zshrc, así no hay que tocar
# el .p10k.zsh (propiedad de root). Para revertir: borra el `source` en .zshrc.
#
# Paleta (xterm-256): ámbar 214/215, grises 234/240/244/245/250, rojo 196.

# Fondo global de los segmentos (ya era 236; lo acerco al #121212 de polybar)
typeset -g POWERLEVEL9K_BACKGROUND=234

# Marco / frame en gris discreto
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='%242F╭─'
typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX='%242F├─'
typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%242F╰─'
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX='%242F─╮'
typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX='%242F─┤'
typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX='%242F─╯'

# OS icon: gris claro neutro
typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=255

# Directorio: ámbar como acento principal
typeset -g POWERLEVEL9K_DIR_FOREGROUND=214
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=244
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=215

# Contexto (user@host): gris; root resaltado en ámbar
typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=245
typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=196   # root en rojo (aviso)

# Reloj y tiempo de ejecución: grises
typeset -g POWERLEVEL9K_TIME_FOREGROUND=244
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=245

# Prompt char: ámbar al ir bien, rojo al fallar (único color "vivo")
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=231
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196

# Status: ok en gris (sin verde), error en rojo
typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=245
typeset -g POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND=245

# Git/VCS en escala mono + ámbar para modificados
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=245
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=245
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=231

# ─────────────────────────────────────────────
#  Look REDONDEADO (rounded) + burbujas por segmento
# ─────────────────────────────────────────────

# Separadores semicirculares (rounded) en vez de los triángulos ''
typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=$''      #
typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=$''     #
typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=$''   #
typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=$''  #

# Extremos del prompt redondeados (cápsula/pill)
typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=$''   #
typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=$''      #
typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=$''
typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=$''

# Línea en blanco antes del prompt (más aire)
typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

# Fondos por segmento: rampa de grises (sin bloque ámbar)
typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=236              # burbuja gris (antes ámbar)
typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=255              # icono claro neutro
typeset -g POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION=$'\ue800'   # logo Bolado (U+E800)
typeset -g POWERLEVEL9K_DIR_BACKGROUND=237                  # ruta: gris medio
typeset -g POWERLEVEL9K_DIR_FOREGROUND=252                  # texto neutro (poco ámbar)
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=231           # anchors en blanco
typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND=235
typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=235
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=236
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=246
typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND=239
typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=250
typeset -g POWERLEVEL9K_VCS_BACKGROUND=238                   # git: gris

# Marco superior pegado a la burbuja (más limpio con el rounded)
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='%242F╭'
typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%242F╰'

# ─────────────────────────────────────────────
#  ROOT: mismo estilo rounded pero con acento ROJO (aviso)
#  (este mismo archivo se sourcea también desde /root)
# ─────────────────────────────────────────────
if [[ $EUID -eq 0 ]]; then
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=88                                          # burbuja roja
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=231
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=203                                       # anchors rojo claro
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196          # prompt char rojo
fi
