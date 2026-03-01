#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════════════╗
# ║                    WELCOME BANNER - Terminal                             ║
# ║                    Ejecutar en .zshrc o manualmente                      ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
RESET='\033[0m'

# Colores 256
C1='\033[38;5;39m'   # Azul claro
C2='\033[38;5;208m'  # Naranja
C3='\033[38;5;82m'   # Verde lima

# Información del sistema
USER_NAME=$(whoami)
HOSTNAME=$(hostname)
KERNEL=$(uname -r)
UPTIME=$(uptime -p | sed 's/up //')
SHELL_NAME=$(basename $SHELL)
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
MEM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
MEM_USED=$(free -h | awk '/^Mem:/ {print $3}')
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')
IP_LOCAL=$(hostname -I | awk '{print $1}')
IP_PUBLIC=$(curl -s --connect-timeout 2 ifconfig.me 2>/dev/null || echo "N/A")

# Hora y saludo
HOUR=$(date +%H)
if [ $HOUR -lt 12 ]; then
    GREETING="Buenos días"
    EMOJI="☀️"
elif [ $HOUR -lt 18 ]; then
    GREETING="Buenas tardes"
    EMOJI="🌤️"
else
    GREETING="Buenas noches"
    EMOJI="🌙"
fi

# Arte ASCII del logo
print_logo() {
    echo -e "${C1}"
    echo "    ██╗  ██╗ █████╗ ██╗     ██╗██████╗ ██╗    ██╗███╗   ███╗"
    echo "    ██║ ██╔╝██╔══██╗██║     ██║██╔══██╗██║    ██║████╗ ████║"
    echo "    █████╔╝ ███████║██║     ██║██████╔╝██║ █╗ ██║██╔████╔██║"
    echo "    ██╔═██╗ ██╔══██║██║     ██║██╔═══╝ ██║███╗██║██║╚██╔╝██║"
    echo "    ██║  ██╗██║  ██║███████╗██║██║     ╚███╔███╔╝██║ ╚═╝ ██║"
    echo "    ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚═╝      ╚══╝╚══╝ ╚═╝     ╚═╝"
    echo -e "${RESET}"
}

# Información en formato de tabla
print_info() {
    echo -e "${C1}  ╭──────────────────────────────────────────────────────────╮${RESET}"
    echo -e "${C1}  │${RESET}   ${BOLD}${GREEN}$GREETING, $USER_NAME! $EMOJI${RESET}"
    echo -e "${C1}  │${RESET}   ${WHITE}$(date '+%A, %d de %B de %Y - %H:%M:%S')${RESET}"
    echo -e "${C1}  ├──────────────────────────────────────────────────────────┤${RESET}"
    echo -e "${C1}  │${RESET}   ${CYAN}󰻀${RESET}  Hostname:    ${WHITE}$HOSTNAME${RESET}"
    echo -e "${C1}  │${RESET}   ${CYAN}${RESET}  Kernel:      ${WHITE}$KERNEL${RESET}"
    echo -e "${C1}  │${RESET}   ${CYAN}󰔛${RESET}  Uptime:      ${WHITE}$UPTIME${RESET}"
    echo -e "${C1}  │${RESET}   ${CYAN}${RESET}  Shell:       ${WHITE}$SHELL_NAME${RESET}"
    echo -e "${C1}  ├──────────────────────────────────────────────────────────┤${RESET}"
    echo -e "${C1}  │${RESET}   ${YELLOW}󰻠${RESET}  CPU:         ${WHITE}${CPU_USAGE}%${RESET}"
    echo -e "${C1}  │${RESET}   ${YELLOW}󰍛${RESET}  RAM:         ${WHITE}$MEM_USED / $MEM_TOTAL${RESET}"
    echo -e "${C1}  │${RESET}   ${YELLOW}󰋊${RESET}  Disk (/):    ${WHITE}$DISK_USAGE used${RESET}"
    echo -e "${C1}  ├──────────────────────────────────────────────────────────┤${RESET}"
    echo -e "${C1}  │${RESET}   ${MAGENTA}󰩟${RESET}  Local IP:    ${WHITE}$IP_LOCAL${RESET}"
    echo -e "${C1}  │${RESET}   ${MAGENTA}󰖟${RESET}  Public IP:   ${WHITE}$IP_PUBLIC${RESET}"
    echo -e "${C1}  ╰──────────────────────────────────────────────────────────╯${RESET}"
}

# Tips aleatorios
print_tip() {
    tips=(
        "💡 Tip: Usa 'cc' para clear con animación"
        "💡 Tip: Doble ESC añade 'sudo' al inicio"
        "💡 Tip: Usa 'hf' para buscar en el historial"
        "💡 Tip: Usa 'vf' para buscar y editar archivos"
        "💡 Tip: Usa 'cpy <cmd>' para copiar output"
        "💡 Tip: Usa 'serve' para servidor HTTP rápido"
        "💡 Tip: Usa 'listener' para reverse shell"
        "💡 Tip: Usa 'qscan <IP>' para nmap rápido"
        "💡 Tip: Usa 'extract <file>' para descomprimir"
        "💡 Tip: Usa 'sysinfo' para info del sistema"
        "💡 Tip: Super+Shift+W abre widgets de EWW"
        "💡 Tip: Usa 'ports' para ver puertos abiertos"
    )
    random_tip=${tips[$RANDOM % ${#tips[@]}]}
    echo -e "\n  ${CYAN}$random_tip${RESET}\n"
}

# Ejecutar
clear
print_logo
print_info
print_tip
