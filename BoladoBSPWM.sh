#!/bin/bash
#
# BoladoBSPWM · lanzador del instalador del tema
# (monocromo + ámbar · barra polybar pill única)
#

ruta="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
chmod +x "$ruta"/install.sh 2>/dev/null

banner() {
    clear
    printf '\033[1;33m'
    cat <<'BANNER'
 ____        _           _       ____ ____  ______        ____  __
| __ )  ___ | | __ _  __| | ___ | __ ) ___||  _ \ \      / /  \/  |
|  _ \ / _ \| |/ _` |/ _` |/ _ \|  _ \___ \| |_) \ \ /\ / /| |\/| |
| |_) | (_) | | (_| | (_| | (_) | |_) |__) |  __/ \ V  V / | |  | |
|____/ \___/|_|\__,_|\__,_|\___/|____/____/|_|     \_/\_/  |_|  |_|
BANNER
    printf '\033[0m'
    echo -e "\033[0;37m        Tema monocromo + ámbar · polybar pill única\033[0m"
    echo -e "\033[1;33m#-------------------------------------------------------------#\033[0m"
    echo -e "\033[1;33m# SELECCIONA UNA OPCIÓN:                                      #\033[0m"
    echo -e "\033[1;33m#-------------------------------------------------------------#\033[0m"
    echo -e "\033[1;33m# (1) Instalar BoladoBSPWM (Kali)                             #\033[0m"
    echo -e "\033[1;33m# (2) Salir                                                   #\033[0m"
    echo -e "\033[1;33m#-------------------------------------------------------------#\033[0m"
}

while true; do
    banner
    read -p "> " opcion
    case "$opcion" in
        1)
            sudo apt update && bash "$ruta"/install.sh
            read -p "Pulsa ENTER para volver al menú..." _
            ;;
        2)
            echo "Saliendo."
            exit 0
            ;;
        *)
            echo "Opción inválida"; sleep 1
            ;;
    esac
done
