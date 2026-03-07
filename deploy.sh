#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║                       KALIPWM DEPLOY                                     ║
# ║        Copia configs y scripts sin reinstalar todo el entorno            ║
# ╚══════════════════════════════════════════════════════════════════════════╝
#
#  Uso:
#    bash deploy.sh          → copia TODO (configs, scripts, wallpapers, fonts)
#    bash deploy.sh --only   → menú interactivo para elegir qué copiar
#    bash deploy.sh --dry    → muestra qué haría sin copiar nada
#
#  Requisito: ejecutar desde la raíz del repo (donde está este archivo).
#  No necesita sudo — todo se instala en $HOME.

set -euo pipefail

# ── Colores ───────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ── Variables ─────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
INTERACTIVE=false
BACKUP_DIR="$HOME/.kalipwm_backup/$(date +%Y%m%d_%H%M%S)"
CHANGES=0

# ── Funciones de mensajes ─────────────────────────────────────────────────
info()    { echo -e "${CYAN}[*]${RESET} $1"; }
success() { echo -e "${GREEN}[+]${RESET} $1"; }
warning() { echo -e "${YELLOW}[!]${RESET} $1"; }
error()   { echo -e "${RED}[-]${RESET} $1"; }
header()  { echo -e "\n${MAGENTA}${BOLD}══ $1 ══${RESET}"; }

# ── Verificación ──────────────────────────────────────────────────────────
check_repo() {
    if [[ ! -d "$SCRIPT_DIR/CONFIGS" ]] || [[ ! -d "$SCRIPT_DIR/SCRIPTS" ]]; then
        error "No se encontró la estructura del repo. Ejecutá el script desde la raíz de kalipwm."
        exit 1
    fi
}

# ── Backup de un path antes de sobreescribir ──────────────────────────────
backup_path() {
    local target="$1"
    if [[ -e "$target" ]]; then
        local rel="${target#$HOME/}"
        local backup_dest="$BACKUP_DIR/$rel"
        mkdir -p "$(dirname "$backup_dest")"
        cp -a "$target" "$backup_dest" 2>/dev/null || true
    fi
}

# ── Copiar con backup y conteo ────────────────────────────────────────────
safe_copy() {
    local src="$1"
    local dest="$2"

    if $DRY_RUN; then
        echo -e "  ${DIM}cp${RESET} $src → $dest"
        return
    fi

    backup_path "$dest"
    mkdir -p "$(dirname "$dest")"
    cp -a "$src" "$dest"
    ((CHANGES++)) || true
}

safe_copy_recursive() {
    local src_dir="$1"
    local dest_dir="$2"

    if $DRY_RUN; then
        echo -e "  ${DIM}cp -r${RESET} $src_dir/ → $dest_dir/"
        return
    fi

    # Backup existing files that will be overwritten
    if [[ -d "$dest_dir" ]]; then
        find "$src_dir" -type f | while read -r f; do
            local rel="${f#$src_dir/}"
            local target="$dest_dir/$rel"
            backup_path "$target"
        done
    fi

    mkdir -p "$dest_dir"
    cp -a "$src_dir"/. "$dest_dir"/
    local count
    count=$(find "$src_dir" -type f | wc -l)
    CHANGES=$((CHANGES + count))
}

# ── Paso 1: Configs de bspwm, sxhkd, polybar, picom, kitty, eww ─────────
deploy_configs() {
    header "Configuraciones (~/.config/)"

    local dirs=(bspwm sxhkd polybar picom kitty eww)
    for dir in "${dirs[@]}"; do
        if [[ -d "$SCRIPT_DIR/CONFIGS/config/$dir" ]]; then
            safe_copy_recursive "$SCRIPT_DIR/CONFIGS/config/$dir" "$HOME/.config/$dir"
            success "$dir"
        else
            warning "$dir no encontrado en el repo, saltando"
        fi
    done
}

# ── Paso 2: Dotfiles (zshrc, p10k, tmux) ─────────────────────────────────
deploy_dotfiles() {
    header "Dotfiles (~/.zshrc, ~/.p10k.zsh, ~/.tmux.conf.local)"

    if [[ -f "$SCRIPT_DIR/CONFIGS/zshrc" ]]; then
        safe_copy "$SCRIPT_DIR/CONFIGS/zshrc" "$HOME/.zshrc"
        success ".zshrc"
    fi

    if [[ -f "$SCRIPT_DIR/CONFIGS/p10k.zsh" ]]; then
        safe_copy "$SCRIPT_DIR/CONFIGS/p10k.zsh" "$HOME/.p10k.zsh"
        success ".p10k.zsh"
    fi

    if [[ -f "$SCRIPT_DIR/CONFIGS/tmux.conf.local" ]]; then
        safe_copy "$SCRIPT_DIR/CONFIGS/tmux.conf.local" "$HOME/.tmux.conf.local"
        success ".tmux.conf.local"
    fi
}

# ── Paso 3: Scripts ───────────────────────────────────────────────────────
deploy_scripts() {
    header "Scripts (~/.config/scripts/)"

    safe_copy_recursive "$SCRIPT_DIR/SCRIPTS" "$HOME/.config/scripts"
    success "Scripts copiados"

    # Generar eww-toggle.sh si no existe
    if [[ ! -f "$HOME/.config/scripts/eww-toggle.sh" ]] && ! $DRY_RUN; then
        cat > "$HOME/.config/scripts/eww-toggle.sh" << 'TOGGLEEOF'
#!/bin/bash
# Toggle sidebar de eww
STATE=$(eww state | grep -c "sidebar")
if eww windows | grep -q "\*sidebar"; then
    eww close sidebar
else
    eww open sidebar
fi
TOGGLEEOF
        success "eww-toggle.sh generado"
    fi
}

# ── Paso 4: Wallpapers ───────────────────────────────────────────────────
deploy_wallpapers() {
    header "Wallpapers (~/Wallpapers/)"

    if [[ -d "$SCRIPT_DIR/WALLPAPERS" ]] && [[ -n "$(ls -A "$SCRIPT_DIR/WALLPAPERS/" 2>/dev/null)" ]]; then
        safe_copy_recursive "$SCRIPT_DIR/WALLPAPERS" "$HOME/Wallpapers"
        success "Wallpapers copiados"
    else
        warning "Carpeta WALLPAPERS vacía o no encontrada"
    fi
}

# ── Paso 5: Fuentes locales del polybar ───────────────────────────────────
deploy_fonts() {
    header "Fuentes (polybar fonts → ~/.local/share/fonts/)"

    local polybar_fonts="$SCRIPT_DIR/CONFIGS/config/polybar/fonts"
    if [[ -d "$polybar_fonts" ]] && [[ -n "$(ls -A "$polybar_fonts/" 2>/dev/null)" ]]; then
        if ! $DRY_RUN; then
            mkdir -p "$HOME/.local/share/fonts"
        fi
        for font in "$polybar_fonts"/*; do
            [[ -f "$font" ]] || continue
            safe_copy "$font" "$HOME/.local/share/fonts/$(basename "$font")"
        done
        if ! $DRY_RUN; then
            fc-cache -f 2>/dev/null || true
        fi
        success "Fuentes del polybar copiadas"
    else
        warning "No se encontraron fuentes en polybar/fonts/"
    fi
}

# ── Paso 6: Permisos ─────────────────────────────────────────────────────
set_permissions() {
    header "Permisos de ejecución"

    if $DRY_RUN; then
        echo -e "  ${DIM}chmod +x en scripts, bspwmrc, launch.sh, etc.${RESET}"
        return
    fi

    chmod +x "$HOME/.config/bspwm/bspwmrc"                    2>/dev/null || true
    chmod +x "$HOME/.config/bspwm/scripts/bspwm_resize"       2>/dev/null || true
    chmod +x "$HOME/.config/polybar/launch.sh"                 2>/dev/null || true
    chmod +x "$HOME/.config/polybar/scripts/"*                 2>/dev/null || true
    chmod +x "$HOME/.config/scripts/"*                         2>/dev/null || true
    chmod +x "$HOME/.config/eww/"*.sh                          2>/dev/null || true
    chmod +x "$HOME/.config/eww/music-widget/"*.sh             2>/dev/null || true

    success "Permisos establecidos"
}

# ── Paso 7: dos2unix (Windows → Linux) ───────────────────────────────────
fix_line_endings() {
    header "Finales de línea (dos2unix)"

    if ! command -v dos2unix &>/dev/null; then
        warning "dos2unix no instalado — saltando (apt install dos2unix)"
        return
    fi

    if $DRY_RUN; then
        echo -e "  ${DIM}dos2unix en ~/.config/{eww,polybar,scripts,bspwm,sxhkd,picom}${RESET}"
        return
    fi

    find "$HOME/.config/eww" "$HOME/.config/polybar" "$HOME/.config/scripts" \
         "$HOME/.config/bspwm" "$HOME/.config/sxhkd" "$HOME/.config/picom" \
         -type f \( \
             -name "*.sh" -o -name "*.conf" -o -name "*.ini" -o \
             -name "*.rasi" -o -name "*.yuck" -o -name "*.scss" -o -name "*.rc" \
         \) -exec dos2unix {} + 2>/dev/null || true

    success "Finales de línea normalizados"
}

# ── Paso 8: Limpieza de cache EWW ────────────────────────────────────────
clean_eww_cache() {
    header "Limpieza de cache EWW"

    if $DRY_RUN; then
        echo -e "  ${DIM}rm -rf ~/.cache/eww${RESET}"
        return
    fi

    rm -rf "$HOME/.cache/eww" 2>/dev/null || true
    success "Cache de EWW limpiada"
}

# ── Paso 9: Crear directorios necesarios ──────────────────────────────────
ensure_dirs() {
    if ! $DRY_RUN; then
        mkdir -p "$HOME/screenshots" 2>/dev/null || true
    fi
}

# ── Menú interactivo ─────────────────────────────────────────────────────
interactive_menu() {
    echo -e "\n${BOLD}${CYAN}¿Qué querés deployar?${RESET}\n"
    echo -e "  ${BOLD}1)${RESET} Configs      (bspwm, sxhkd, polybar, picom, kitty, eww)"
    echo -e "  ${BOLD}2)${RESET} Dotfiles     (.zshrc, .p10k.zsh, .tmux.conf.local)"
    echo -e "  ${BOLD}3)${RESET} Scripts      (~/.config/scripts/)"
    echo -e "  ${BOLD}4)${RESET} Wallpapers   (~/Wallpapers/)"
    echo -e "  ${BOLD}5)${RESET} Fuentes      (polybar fonts → ~/.local/share/fonts/)"
    echo -e "  ${BOLD}6)${RESET} Todo"
    echo -e "  ${BOLD}0)${RESET} Salir\n"

    read -rp "Elegí opciones separadas por espacio (ej: 1 3 5): " choices

    local do_configs=false do_dotfiles=false do_scripts=false
    local do_wallpapers=false do_fonts=false

    for c in $choices; do
        case $c in
            1) do_configs=true ;;
            2) do_dotfiles=true ;;
            3) do_scripts=true ;;
            4) do_wallpapers=true ;;
            5) do_fonts=true ;;
            6) do_configs=true; do_dotfiles=true; do_scripts=true
               do_wallpapers=true; do_fonts=true ;;
            0) info "Saliendo."; exit 0 ;;
            *) warning "Opción $c no reconocida, saltando" ;;
        esac
    done

    $do_configs    && deploy_configs
    $do_dotfiles   && deploy_dotfiles
    $do_scripts    && deploy_scripts
    $do_wallpapers && deploy_wallpapers
    $do_fonts      && deploy_fonts

    # Siempre fijar permisos y line endings si se copió algo
    if $do_configs || $do_scripts; then
        set_permissions
        fix_line_endings
        clean_eww_cache
        ensure_dirs
    fi
}

# ── Main ──────────────────────────────────────────────────────────────────
main() {
    echo -e "${MAGENTA}${BOLD}"
    echo "  ╔═══════════════════════════════════════╗"
    echo "  ║         KALIPWM  ⚡  DEPLOY           ║"
    echo "  ╚═══════════════════════════════════════╝"
    echo -e "${RESET}"

    check_repo

    # Parsear argumentos
    for arg in "$@"; do
        case $arg in
            --dry)  DRY_RUN=true; warning "Modo dry-run — no se copiará nada" ;;
            --only) INTERACTIVE=true ;;
            --help|-h)
                echo "Uso: bash deploy.sh [--only] [--dry]"
                echo "  (sin args)  Copia todo"
                echo "  --only      Menú interactivo"
                echo "  --dry       Muestra qué haría sin copiar"
                exit 0
                ;;
        esac
    done

    if $INTERACTIVE; then
        interactive_menu
    else
        # Deploy completo
        info "Deployando todo desde ${BOLD}$SCRIPT_DIR${RESET}"

        if ! $DRY_RUN; then
            mkdir -p "$BACKUP_DIR"
            info "Backup de archivos existentes en ${DIM}$BACKUP_DIR${RESET}"
        fi

        deploy_configs
        deploy_dotfiles
        deploy_scripts
        deploy_wallpapers
        deploy_fonts
        set_permissions
        fix_line_endings
        clean_eww_cache
        ensure_dirs
    fi

    # Resumen
    echo ""
    if $DRY_RUN; then
        info "Dry-run completado — nada fue copiado."
    else
        echo -e "${GREEN}${BOLD}╔═══════════════════════════════════════╗${RESET}"
        echo -e "${GREEN}${BOLD}║     ✅  Deploy completado             ║${RESET}"
        echo -e "${GREEN}${BOLD}╚═══════════════════════════════════════╝${RESET}"
        echo ""
        success "$CHANGES archivos copiados"
        info "Backup en: ${DIM}$BACKUP_DIR${RESET}"
        echo ""
        echo -e "  ${YELLOW}Ahora podés:${RESET}"
        echo -e "    • ${BOLD}bspc wm -r${RESET}                  Recargar BSPWM"
        echo -e "    • ${BOLD}Super + Shift + E${RESET}            Reiniciar sesión"
        echo -e "    • ${BOLD}~/.config/polybar/launch.sh${RESET}  Relanzar polybar"
        echo -e "    • ${BOLD}eww reload${RESET}                   Recargar EWW"
        echo ""
    fi
}

main "$@"
