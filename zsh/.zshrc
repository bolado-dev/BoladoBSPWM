# Fix the Java Problem
export _JAVA_AWT_WM_NONREPARENTING=1

# Enable Powerlevel10k instant prompt. Should stay at the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set up the prompt

autoload -Uz promptinit
promptinit
prompt adam1

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
# Overrides de color monocromo + ámbar (casa con el wallpaper / polybar)
[[ -f ~/.config/p10k-mono.zsh ]] && source ~/.config/p10k-mono.zsh

# Manual configuration

PATH=/root/.local/bin:/snap/bin:/usr/sandbox/:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/usr/share/games:/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games

# Custom Aliases

alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'
alias cat='/bin/batcat --paging=never'
alias catn='cat'
alias catnl='batcat'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Plugins
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#source /usr/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f ~/.config/zsh/sudo.plugin.zsh ]] && source ~/.config/zsh/sudo.plugin.zsh
# Utilidades de pentest (newbox, qnote, cdt, lhost) + power-ups de shell
[[ -f ~/.config/zsh/pentest.zsh ]] && source ~/.config/zsh/pentest.zsh

# Functions
function mkt(){
	mkdir {nmap,content,exploits,scripts}
}

# Extract nmap information
function extractPorts(){
	ports="$(cat $1 | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
	ip_address="$(cat $1 | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | sort -u | head -n 1)"
	echo -e "\n[*] Extracting information...\n" > extractPorts.tmp
	echo -e "\t[*] IP Address: $ip_address"  >> extractPorts.tmp
	echo -e "\t[*] Open ports: $ports\n"  >> extractPorts.tmp
	echo $ports | tr -d '\n' | xclip -sel clip
	echo -e "[*] Ports copied to clipboard\n"  >> extractPorts.tmp
	cat extractPorts.tmp; rm extractPorts.tmp
}

# Settarget

function settarget(){
#Función por defecto
#----------------------------
#	if [ $# -eq 1 ]; then
#	echo $1 > ~/.config/bin/target
#	elif [ $# -gt 2 ]; then
#	echo "settarget [IP] [NAME] | settarget [IP]"
#	else
#	echo $1 $2 > ~/.config/bin/target
#	fi
#
#Funcion mejorada
#----------------------------
	/usr/local/bin/settarget "$@"
}

# Set 'man' colors
function man() {
    env \
    LESS_TERMCAP_mb=$'\e[01;31m' \
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    man "$@"
}

# fzf improvement
function fzf-lovely(){

	if [ "$1" = "h" ]; then
		fzf -m --reverse --preview-window down:20 --preview '[[ $(file --mime {}) =~ binary ]] &&
 	                echo {} is a binary file ||
	                 (bat --style=numbers --color=always {} ||
	                  highlight -O ansi -l {} ||
	                  coderay {} ||
	                  rougify {} ||
	                  cat {}) 2> /dev/null | head -500'

	else
	        fzf -m --preview '[[ $(file --mime {}) =~ binary ]] &&
	                         echo {} is a binary file ||
	                         (bat --style=numbers --color=always {} ||
	                          highlight -O ansi -l {} ||
	                         coderay {} ||
	                          rougify {} ||
	                          cat {}) 2> /dev/null | head -500'
	fi
}

function rmk(){
	scrub -p dod $1
	shred -zun 10 -v $1
}

function htb() {
	sudo openvpn /home/alejandro/VPNs/htb.ovpn
}

# Alterna el layout del teclado entre español e inglés.
# Sin argumento: cambia al que no esté activo. Con 'es'/'us': lo fuerza.
# El cambio rápido también funciona con Alt+Shift (configurado en bspwmrc).
function kbtoggle() {
	emulate -L zsh
	local cur target
	cur="$(setxkbmap -query 2>/dev/null | awk '/^layout:/{print $2}' | cut -d, -f1)"
	case "$1" in
		es|us) target="$1" ;;
		"")    [[ "$cur" == "es" ]] && target="us" || target="es" ;;
		*)     echo "uso: kbtoggle [es|us]"; return 1 ;;
	esac
	setxkbmap -layout "${target},$([[ $target == es ]] && echo us || echo es)" \
		-option grp:alt_shift_toggle
	echo "teclado -> $target"
}

# Pide pegar el "Copy as cURL" de una petición a labs.hackthebox.com
# (DevTools -> Network -> clic dcho en la petición -> Copy -> Copy as cURL),
# extrae el "Bearer <token>" y lo guarda en ~/.config/htb/token (chmod 600).
# Imprime el token por stdout.
function _htbimg_grab_token() {
	emulate -L zsh
	local tf="${XDG_CONFIG_HOME:-$HOME/.config}/htb/token"
	print -u2 "Pega el 'Copy as cURL' de una petición a labs.hackthebox.com y pulsa Ctrl-D:"
	local paste token
	paste="$(cat)"
	token="$(printf '%s' "$paste" | grep -oiP 'Bearer\s+\K[A-Za-z0-9._-]+' | head -1)"
	if [[ -z "$token" ]]; then
		print -u2 "No encontré ningún 'Bearer <token>' en lo que pegaste."
		return 1
	fi
	mkdir -p "${tf:h}"
	print -r -- "$token" > "$tf"
	chmod 600 "$tf"
	print -u2 "✓ Token guardado en $tf"
	print -r -- "$token"
}

# Descarga el avatar de una máquina de HTB a partir de su enlace o nombre.
# Uso:  htbimg <url-o-nombre> [salida]
# Ej.:  htbimg 'https://app.hackthebox.com/machines/Photobomb?sort_by=created_at'
#       htbimg Photobomb content/writeups/photobomb/cover.png
# La 1ª vez pide el 'Copy as cURL' y guarda el token; luego lo reutiliza solo.
# Si está definida $HTB_TOKEN, tiene prioridad sobre el fichero.
function htbimg() {
	emulate -L zsh
	local input="$1"
	if [[ -z "$input" ]]; then
		print -u2 "Uso: htbimg <url-o-nombre-HTB> [salida]"
		return 1
	fi

	# token: $HTB_TOKEN > fichero guardado > pedir 'Copy as cURL'.
	local tf="${XDG_CONFIG_HOME:-$HOME/.config}/htb/token"
	local token=""
	if [[ -n "$HTB_TOKEN" ]]; then
		token="$HTB_TOKEN"
	elif [[ -r "$tf" ]]; then
		token="$(<"$tf")"
	fi
	if [[ -z "$token" ]]; then
		token="$(_htbimg_grab_token)" || return 1
	fi

	# slug = último segmento tras /machines/ (o el nombre tal cual), sin query.
	local slug="${input##*/machines/}"
	slug="${slug%%\?*}"
	slug="${slug%%/*}"

	local api="https://labs.hackthebox.com/api/v4/machine/profile/${slug}"

	# Llama a la API; si el token guardado caducó, pide uno nuevo y reintenta.
	local json
	json="$(curl -sf -H "Authorization: Bearer ${token}" \
		-H "Accept: application/json, text/plain, */*" \
		-H "User-Agent: Mozilla/5.0" "$api")"
	if [[ $? -ne 0 ]]; then
		print -u2 "La API falló (token caducado/inválido o sin conexión). Pega un 'Copy as cURL' nuevo."
		token="$(_htbimg_grab_token)" || return 1
		json="$(curl -sf -H "Authorization: Bearer ${token}" \
			-H "Accept: application/json, text/plain, */*" \
			-H "User-Agent: Mozilla/5.0" "$api")" || {
			print -u2 "Sigue fallando la API para '${slug}'."
			return 1
		}
	fi

	local avatar name
	avatar="$(printf '%s' "$json" | python3 -c 'import sys,json; print(json.load(sys.stdin)["info"].get("avatar",""))' 2>/dev/null)"
	name="$(printf '%s' "$json" | python3 -c 'import sys,json; print(json.load(sys.stdin)["info"].get("name",""))' 2>/dev/null)"
	if [[ -z "$avatar" ]]; then
		print -u2 "No encontré avatar en la respuesta de HTB para '${slug}'."
		return 1
	fi
	# La API suele devolver /avatars/<hash>.png, pero HTB lo sirve en
	# /storage/avatars/<hash>.png. Probamos varias rutas candidatas.
	local -aU urls
	if [[ "$avatar" == http* ]]; then
		urls=("$avatar")
	else
		local fileimg="${avatar##*/}"
		urls=(
			"https://htb-mp-prod-public-storage.s3.eu-central-1.amazonaws.com/avatars/${fileimg}"
			"https://labs.hackthebox.com/storage/avatars/${fileimg}"
			"https://labs.hackthebox.com${avatar}"
		)
	fi

	local out="$2"
	if [[ -z "$out" ]]; then
		local ext="${urls[1]##*.}"; ext="${ext%%\?*}"
		[[ -z "$ext" || "$ext" == "${urls[1]}" ]] && ext="png"
		out="${name:-$slug}.${ext}"
	fi

	# Descarga: prueba cada candidata, primero sin auth y luego con Bearer.
	local u ok=0
	for u in "${urls[@]}"; do
		if curl -sfL -o "$out" "$u" 2>/dev/null \
		|| curl -sfL -H "Authorization: Bearer ${token}" -o "$out" "$u" 2>/dev/null; then
			ok=1; break
		fi
	done
	if (( ! ok )); then
		print -u2 "No pude descargar la imagen. avatar(API)=${avatar}"
		print -u2 "Probé:"; printf '  %s\n' "${urls[@]}" >&2
		return 1
	fi
	echo "✓ ${name:-$slug} -> ${out}  (desde ${u})"
}

# Finalize Powerlevel10k instant prompt. Should stay at the bottom of ~/.zshrc.
(( ! ${+functions[p10k-instant-prompt-finalize]} )) || p10k-instant-prompt-finalize 

bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
source ~/.powerlevel10k/powerlevel10k.zsh-theme

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pnpm
export PNPM_HOME="/home/alejandro/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# atuin — historial buscable (Ctrl-R). --disable-up-arrow: la flecha arriba
# sigue siendo el comando anterior de siempre. Va al final (sitio recomendado).
[ -f "$HOME/.atuin/bin/env" ] && . "$HOME/.atuin/bin/env"
command -v atuin >/dev/null 2>&1 && eval "$(atuin init zsh --disable-up-arrow)"
