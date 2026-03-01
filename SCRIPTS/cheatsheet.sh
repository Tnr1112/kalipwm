#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════════════╗
# ║                    CHEATSHEET - Atajos y comandos                        ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# Colores
C1='\033[38;5;39m'   # Azul
C2='\033[38;5;82m'   # Verde
C3='\033[38;5;208m'  # Naranja
C4='\033[38;5;213m'  # Rosa
WHITE='\033[0;37m'
BOLD='\033[1m'
RESET='\033[0m'

show_help() {
    echo -e "${C1}╔══════════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${C1}║${RESET}                     ${BOLD}📚 CHEATSHEET - KALIPWM 📚${RESET}                         ${C1}║${RESET}"
    echo -e "${C1}╚══════════════════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    
    echo -e "${C2}┌─────────────────────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${C2}│${RESET} ${BOLD}⌨️  ATAJOS DE TECLADO (BSPWM)${RESET}                                          ${C2}│${RESET}"
    echo -e "${C2}├─────────────────────────────────────────────────────────────────────────┤${RESET}"
    echo -e "${C2}│${RESET} ${C3}Super + Enter${RESET}        Terminal                                          ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}Super + D${RESET}            Launcher (Rofi)                                   ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}Super + W${RESET}            Cerrar ventana                                    ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}Super + F${RESET}            Pantalla completa                                 ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}Super + S${RESET}            Ventana flotante                                  ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}Super + T${RESET}            Ventana tiled                                     ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}Super + [1-9]${RESET}        Cambiar workspace                                 ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}Super + Shift + [1-9]${RESET} Mover ventana a workspace                        ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}Super + Flechas${RESET}      Cambiar foco                                      ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}Super + Shift + Flechas${RESET} Mover ventana                                  ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}Super + Alt + Flechas${RESET} Redimensionar ventana                            ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}Super + Escape${RESET}       Recargar sxhkd                                    ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}Super + Shift + Q${RESET}    Salir de BSPWM                                    ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}Super + Shift + E${RESET}    Reiniciar BSPWM                                   ${C2}│${RESET}"
    echo -e "${C2}└─────────────────────────────────────────────────────────────────────────┘${RESET}"
    echo ""
    
    echo -e "${C4}┌─────────────────────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${C4}│${RESET} ${BOLD}🔧 APLICACIONES RÁPIDAS${RESET}                                                ${C4}│${RESET}"
    echo -e "${C4}├─────────────────────────────────────────────────────────────────────────┤${RESET}"
    echo -e "${C4}│${RESET} ${C3}Super + Shift + F${RESET}    Firefox                                           ${C4}│${RESET}"
    echo -e "${C4}│${RESET} ${C3}Super + Shift + S${RESET}    Flameshot (screenshot)                            ${C4}│${RESET}"
    echo -e "${C4}│${RESET} ${C3}Super + E${RESET}            Thunar (archivos)                                 ${C4}│${RESET}"
    echo -e "${C4}│${RESET} ${C3}Super + Shift + B${RESET}    Burpsuite                                         ${C4}│${RESET}"
    echo -e "${C4}│${RESET} ${C3}Super + V${RESET}            Clipboard history                                 ${C4}│${RESET}"
    echo -e "${C4}│${RESET} ${C3}Super + Shift + W${RESET}    Toggle EWW sidebar                                ${C4}│${RESET}"
    echo -e "${C4}│${RESET} ${C3}Super + Shift + M${RESET}    Toggle music widget                               ${C4}│${RESET}"
    echo -e "${C4}│${RESET} ${C3}Super + Shift + X${RESET}    Toggle system stats                               ${C4}│${RESET}"
    echo -e "${C4}└─────────────────────────────────────────────────────────────────────────┘${RESET}"
    echo ""
    
    echo -e "${C1}┌─────────────────────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${C1}│${RESET} ${BOLD}🐚 COMANDOS SHELL CUSTOM${RESET}                                               ${C1}│${RESET}"
    echo -e "${C1}├─────────────────────────────────────────────────────────────────────────┤${RESET}"
    echo -e "${C1}│${RESET} ${C3}cc${RESET}                   Clear con animación                               ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}cm${RESET}                   Clear con efecto matrix                           ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}ESC ESC${RESET}              Añade sudo al inicio                              ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}mkcd <dir>${RESET}           Crear directorio y entrar                         ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}extract <file>${RESET}       Extraer cualquier archivo                         ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}cpy <cmd>${RESET}            Copiar output al clipboard                        ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}cpf <file>${RESET}           Copiar contenido de archivo                       ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}hf${RESET}                   Buscar en historial (fzf)                         ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}vf${RESET}                   Buscar archivo y editar (nvim)                    ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}cdf${RESET}                  Buscar directorio y cd                            ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}ports [n]${RESET}            Ver puertos en uso                                ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}sysinfo${RESET}              Info del sistema                                  ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}reload${RESET}               Recargar .zshrc                                   ${C1}│${RESET}"
    echo -e "${C1}└─────────────────────────────────────────────────────────────────────────┘${RESET}"
    echo ""
    
    echo -e "${C2}┌─────────────────────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${C2}│${RESET} ${BOLD}🔓 PENTESTING${RESET}                                                         ${C2}│${RESET}"
    echo -e "${C2}├─────────────────────────────────────────────────────────────────────────┤${RESET}"
    echo -e "${C2}│${RESET} ${C3}settarget <ip>${RESET}       Establecer target                                 ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}cleartarget${RESET}          Limpiar target                                    ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}extractPorts <file>${RESET}  Extraer puertos de nmap                           ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}mkt${RESET}                  Crear estructura de proyecto                      ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}qscan <ip>${RESET}           Nmap rápido                                       ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}fullscan <ip>${RESET}        Escaneo completo de puertos                       ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}isalive <ip>${RESET}         Verificar si host está vivo                       ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}serve [port]${RESET}         Servidor HTTP (default 8000)                      ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}listener [port]${RESET}      Reverse shell listener (4444)                     ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}sploit <term>${RESET}        Buscar en searchsploit                            ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}rmk <file>${RESET}           Borrado seguro                                    ${C2}│${RESET}"
    echo -e "${C2}└─────────────────────────────────────────────────────────────────────────┘${RESET}"
    echo ""
    
    echo -e "${C4}┌─────────────────────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${C4}│${RESET} ${BOLD}📁 ALIASES ÚTILES${RESET}                                                      ${C4}│${RESET}"
    echo -e "${C4}├─────────────────────────────────────────────────────────────────────────┤${RESET}"
    echo -e "${C4}│${RESET} ${C3}ll, la, lla${RESET}          Listados con lsd                                  ${C4}│${RESET}"
    echo -e "${C4}│${RESET} ${C3}cat${RESET}                  batcat (syntax highlight)                         ${C4}│${RESET}"
    echo -e "${C4}│${RESET} ${C3}myip${RESET}                 IP pública                                        ${C4}│${RESET}"
    echo -e "${C4}│${RESET} ${C3}localip${RESET}              IP local                                          ${C4}│${RESET}"
    echo -e "${C4}│${RESET} ${C3}openports${RESET}            Ver puertos abiertos                              ${C4}│${RESET}"
    echo -e "${C4}│${RESET} ${C3}update${RESET}               apt update && upgrade                             ${C4}│${RESET}"
    echo -e "${C4}│${RESET} ${C3}gs, ga, gc, gp${RESET}       Git shortcuts                                     ${C4}│${RESET}"
    echo -e "${C4}│${RESET} ${C3}.. / ... / ....${RESET}      Navegación rápida                                 ${C4}│${RESET}"
    echo -e "${C4}└─────────────────────────────────────────────────────────────────────────┘${RESET}"
    echo ""
    
    echo -e "${C1}┌─────────────────────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${C1}│${RESET} ${BOLD}🐱 KITTY TERMINAL${RESET}                                                      ${C1}│${RESET}"
    echo -e "${C1}├─────────────────────────────────────────────────────────────────────────┤${RESET}"
    echo -e "${C1}│${RESET} ${BOLD}✨ Animaciones (cursor_trail + pixel_scroll):${RESET}                          ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}cursor_trail${RESET}         Rastro animado al mover cursor                    ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}pixel_scroll${RESET}         Smooth scrolling real (touchpad)                  ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}scrollbar${RESET}            Barra de scroll visual interactiva                ${C1}│${RESET}"
    echo -e "${C1}│${RESET}                                                                         ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${BOLD}Splits & Layouts:${RESET}                                                      ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Ctrl+Shift+-${RESET}         Split horizontal                                  ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Ctrl+Shift+\\${RESET}         Split vertical                                    ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Alt+Flechas${RESET}          Mover entre splits                                ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Ctrl+Shift+Flechas${RESET}   Redimensionar split                               ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Ctrl+Shift+L${RESET}         Cambiar layout                                    ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Ctrl+Alt+T/G/S/Z${RESET}     Layout tall/grid/splits/stack                     ${C1}│${RESET}"
    echo -e "${C1}│${RESET}                                                                         ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${BOLD}Hints (copiar inteligente):${RESET}                                            ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Ctrl+Shift+E${RESET}         Abrir URLs                                        ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Ctrl+Shift+P > U${RESET}     Copiar URL                                        ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Ctrl+Shift+P > F${RESET}     Copiar path                                       ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Ctrl+Shift+P > H${RESET}     Copiar hash (git)                                 ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Ctrl+Shift+P > I${RESET}     Copiar IP                                         ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Ctrl+Shift+P > L${RESET}     Copiar línea                                      ${C1}│${RESET}"
    echo -e "${C1}│${RESET}                                                                         ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${BOLD}Marcadores (highlight):${RESET}                                                ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Ctrl+Shift+M > E${RESET}     Marcar errores (rojo)                             ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Ctrl+Shift+M > W${RESET}     Marcar warnings (amarillo)                        ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Ctrl+Shift+M > S${RESET}     Marcar success (verde)                            ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Ctrl+Shift+M > I${RESET}     Marcar IPs (azul)                                 ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Ctrl+Shift+M > C${RESET}     Limpiar marcadores                                ${C1}│${RESET}"
    echo -e "${C1}│${RESET}                                                                         ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${BOLD}Tabs:${RESET}                                                                  ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Ctrl+Shift+T${RESET}         Nuevo tab                                         ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Ctrl+Shift+[1-9]${RESET}     Ir a tab N                                        ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Ctrl+Shift+,/.${RESET}       Mover tab izq/der                                 ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Ctrl+Shift+Alt+T${RESET}     Renombrar tab                                     ${C1}│${RESET}"
    echo -e "${C1}│${RESET}                                                                         ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${BOLD}Scrollback & Scroll:${RESET}                                                   ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Ctrl+Shift+H${RESET}         Ver scrollback completo                           ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Ctrl+Shift+G${RESET}         Ver output del último comando                     ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Ctrl+Shift+K/J${RESET}       Scroll línea arriba/abajo                         ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Shift+PgUp/PgDn${RESET}      Scroll página arriba/abajo                        ${C1}│${RESET}"
    echo -e "${C1}│${RESET} ${C3}Ctrl++/-/0${RESET}           Zoom fuente                                       ${C1}│${RESET}"
    echo -e "${C1}└─────────────────────────────────────────────────────────────────────────┘${RESET}"
    echo ""
    
    echo -e "${C2}┌─────────────────────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${C2}│${RESET} ${BOLD}🐱 FUNCIONES KITTY (zsh)${RESET}                                                ${C2}│${RESET}"
    echo -e "${C2}├─────────────────────────────────────────────────────────────────────────┤${RESET}"
    echo -e "${C2}│${RESET} ${C3}icat <img>${RESET}           Ver imagen en terminal                            ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}img <img> [w]${RESET}        Ver imagen con tamaño                             ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}imgurl <url>${RESET}         Ver imagen desde URL                              ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}kdiff <a> <b>${RESET}        Diff visual lado a lado                           ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}kssh <host>${RESET}          SSH con integración kitty                         ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}clk${RESET}                  Clear con animación kitty                         ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}kpentest${RESET}             Crear layout de pentesting                        ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}ktab / knew${RESET}          Abrir nuevo tab/ventana                           ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}kcolors${RESET}              Mostrar paleta de colores                         ${C2}│${RESET}"
    echo -e "${C2}│${RESET} ${C3}kreload${RESET}              Recargar config de kitty                          ${C2}│${RESET}"
    echo -e "${C2}└─────────────────────────────────────────────────────────────────────────┘${RESET}"
    echo ""
}

# Menú interactivo si se usa fzf
interactive_mode() {
    if command -v fzf &> /dev/null; then
        categories=(
            "1. Atajos de teclado (BSPWM)"
            "2. Aplicaciones rápidas"
            "3. Comandos shell custom"
            "4. Pentesting"
            "5. Aliases útiles"
            "6. Ver todo"
        )
        
        selected=$(printf '%s\n' "${categories[@]}" | fzf --prompt="Selecciona categoría: " --height=10)
        
        case "$selected" in
            "6. Ver todo") show_help ;;
            *) show_help | less -R ;;
        esac
    else
        show_help | less -R
    fi
}

# Main
if [ "$1" = "-i" ]; then
    interactive_mode
else
    show_help | less -R
fi
