# Overrides Powerlevel10k — Tokyo Night · Kali pentester (one-line)
# ──────────────────────────────────────────────────────────────────
# Una sola línea, sin marco. Segmentos visibles solo cuando aportan:
# logo Bolado · user@host · dir · git · target HTB · IP tun0 · ❯
# Derecha: exit code (sólo error) · duración · reloj
#
# Paleta xterm-256: violeta 141 · cyan 117 · verde 46 · ámbar 215 · rojo 210

# ─────────────────────────────────────────────
#  Elementos del prompt (sin newline → one-line)
# ─────────────────────────────────────────────
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  os_icon
  context
  dir
  vcs
  custom_htb_target
  vpn_ip
  prompt_char
)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  status
  command_execution_time
  time
)

# Sin línea en blanco extra (one-line denso)
typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false

# ─────────────────────────────────────────────
#  Sin marco (sin ╭ ╰ ├)
# ─────────────────────────────────────────────
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=
typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX=
typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX=
typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX=
typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX=

# ─────────────────────────────────────────────
#  Estilo plano (sin pills, separación por espacios simples)
# ─────────────────────────────────────────────
typeset -g POWERLEVEL9K_BACKGROUND=
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_MIDDLE_WHITESPACE=' '
typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=' '
typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=' '
typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=' '
typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=' '
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_PROMPT_FIRST_SEGMENT_START_SYMBOL=
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_PROMPT_LAST_SEGMENT_END_SYMBOL=

# ─────────────────────────────────────────────
#  OS icon (logo Bolado en violeta)
# ─────────────────────────────────────────────
typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=103
typeset -g POWERLEVEL9K_OS_ICON_CONTENT_EXPANSION=$''

# ─────────────────────────────────────────────
#  Context (user@host) — siempre visible
#  (anula la línea del .p10k.zsh que oculta el contexto local sin sudo)
# ─────────────────────────────────────────────
typeset -g POWERLEVEL9K_ALWAYS_SHOW_CONTEXT=true
typeset -g POWERLEVEL9K_ALWAYS_SHOW_USER=true
typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'
typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_TEMPLATE='%n@%m'
typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE='%n@%m'
typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_CONTENT_EXPANSION='${P9K_CONTENT}'
typeset -g POWERLEVEL9K_CONTEXT_SUDO_CONTENT_EXPANSION='${P9K_CONTENT}'
typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_VISUAL_IDENTIFIER_EXPANSION=
typeset -g POWERLEVEL9K_CONTEXT_SUDO_VISUAL_IDENTIFIER_EXPANSION=
typeset -g POWERLEVEL9K_CONTEXT_PREFIX=
typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_FOREGROUND=110
typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=131
typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_BACKGROUND=
typeset -g POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND=

# ─────────────────────────────────────────────
#  Directorio (compactado a unique)
# ─────────────────────────────────────────────
typeset -g POWERLEVEL9K_DIR_FOREGROUND=187
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=60
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=103
typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_DIR_CONTENT_EXPANSION='${P9K_CONTENT}'

# ─────────────────────────────────────────────
#  Git / VCS
# ─────────────────────────────────────────────
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=101
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=245
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=110
typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${P9K_CONTENT}'

# ─────────────────────────────────────────────
#  Custom: Target HTB activo (~/.config/htb_target, formato "IP NAME")
#  Solo aparece cuando hay target seteado
# ─────────────────────────────────────────────
typeset -g POWERLEVEL9K_CUSTOM_HTB_TARGET="cat \$HOME/.config/htb_target 2>/dev/null"
typeset -g POWERLEVEL9K_CUSTOM_HTB_TARGET_FOREGROUND=179
typeset -g POWERLEVEL9K_CUSTOM_HTB_TARGET_VISUAL_IDENTIFIER_EXPANSION='⌖'
typeset -g POWERLEVEL9K_CUSTOM_HTB_TARGET_BACKGROUND=

# ─────────────────────────────────────────────
#  VPN IP (built-in) — tun0 en verde, oculto si VPN abajo
# ─────────────────────────────────────────────
typeset -g POWERLEVEL9K_VPN_IP_INTERFACES='tun*'
typeset -g POWERLEVEL9K_VPN_IP_FOREGROUND=101
typeset -g POWERLEVEL9K_VPN_IP_BACKGROUND=
typeset -g POWERLEVEL9K_VPN_IP_VISUAL_IDENTIFIER_EXPANSION='󰒍'
typeset -g POWERLEVEL9K_VPN_IP_SHOW_ALL=false

# ─────────────────────────────────────────────
#  Lado derecho
# ─────────────────────────────────────────────
typeset -g POWERLEVEL9K_STATUS_OK=false
typeset -g POWERLEVEL9K_STATUS_ERROR=true
typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=131
typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='✘'

typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=60
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=2
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_VISUAL_IDENTIFIER_EXPANSION='󰔛'

typeset -g POWERLEVEL9K_TIME_FOREGROUND=60
typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M}'

# ─────────────────────────────────────────────
#  Prompt char ❯ : violeta al ir bien, rojo al fallar
# ─────────────────────────────────────────────
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=103
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=131
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'

# ─────────────────────────────────────────────
#  ROOT: acentos en rojo (aviso visual fuerte)
# ─────────────────────────────────────────────
if [[ $EUID -eq 0 ]]; then
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=131
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=131
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=224
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=131
fi
