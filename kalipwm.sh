#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════════════╗
# ║                      KALIPWM INSTALLER                                   ║
# ║              Entorno de hacking profesional para Kali                    ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ═══════════════════════════════════════════════════════════════════════════
# SISTEMA DE LOG Y ERRORES
# ═══════════════════════════════════════════════════════════════════════════

LOG_FILE="/tmp/kalipwm_install_$(date +%Y%m%d_%H%M%S).log"
FAILED_STEPS=()
CURRENT_STEP=""
TOTAL_STEPS=26
CURRENT_STEP_NUM=0

# Función para mensajes
info() { echo -e "${BLUE}[*]${RESET} $1"; echo "[INFO] $1" >> "$LOG_FILE"; }
success() { echo -e "${GREEN}[+]${RESET} $1"; echo "[SUCCESS] $1" >> "$LOG_FILE"; }
warning() { echo -e "${YELLOW}[!]${RESET} $1"; echo "[WARNING] $1" >> "$LOG_FILE"; }
error() { echo -e "${RED}[-]${RESET} $1"; echo "[ERROR] $1" >> "$LOG_FILE"; }

# Función para verificar si un comando existe
command_exists() { command -v "$1" &> /dev/null; }

# ═══════════════════════════════════════════════════════════════════════════
# BARRA DE PROGRESO
# ═══════════════════════════════════════════════════════════════════════════

show_progress() {
    local current=$1
    local total=$2
    local step_name=$3
    local percent=$((current * 100 / total))
    local filled=$((percent / 2))
    local empty=$((50 - filled))
    
    # Construir barra
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    
    # Limpiar línea y mostrar progreso
    printf "\r${CYAN}[${bar}]${RESET} ${BOLD}%3d%%${RESET} ${DIM}│${RESET} ${MAGENTA}%s${RESET}                    " "$percent" "$step_name"
}

# Iniciar nuevo paso
start_step() {
    CURRENT_STEP="$1"
    ((CURRENT_STEP_NUM++))
    echo ""
    show_progress $CURRENT_STEP_NUM $TOTAL_STEPS "$CURRENT_STEP"
    echo ""
    info "Iniciando: $CURRENT_STEP"
    echo "========== STEP: $CURRENT_STEP ==========" >> "$LOG_FILE"
}

# Finalizar paso con éxito
finish_step() {
    success "✓ Completado: $CURRENT_STEP"
}

# Registrar fallo (pero continuar)
fail_step() {
    local reason="${1:-Error desconocido}"
    FAILED_STEPS+=("$CURRENT_STEP: $reason")
    error "✗ Falló: $CURRENT_STEP - $reason"
    warning "Continuando con el siguiente paso..."
}

# ═══════════════════════════════════════════════════════════════════════════
# FUNCIONES DE INSTALACIÓN CON REINTENTOS
# ═══════════════════════════════════════════════════════════════════════════

# Instalar paquetes apt con reintentos y progreso
safe_install() {
    local max_retries=3
    local retry=0
    local packages="$*"
    
    while [ $retry -lt $max_retries ]; do
        echo -e "${DIM}  Intento $((retry+1))/$max_retries: apt install $packages${RESET}"
        if sudo apt install -y $packages >> "$LOG_FILE" 2>&1; then
            return 0
        fi
        ((retry++))
        if [ $retry -lt $max_retries ]; then
            warning "Reintentando... ($retry/$max_retries)"
            sleep 1
        fi
    done
    error "Falló la instalación de: $packages (ver log: $LOG_FILE)"
    return 1
}

# Clonar repositorio git con reintentos
# Uso: safe_git_clone <url> <dest> [--full]
# --full: clonación completa (necesaria para submodules)
safe_git_clone() {
    local url="$1"
    local dest="$2"
    local full_clone=false
    local max_retries=3
    local retry=0
    
    # Detectar si necesita clone completo
    [[ "$3" == "--full" ]] && full_clone=true
    
    # Si existe, eliminarlo primero
    [ -d "$dest" ] && rm -rf "$dest"
    
    while [ $retry -lt $max_retries ]; do
        echo -e "${DIM}  Intento $((retry+1))/$max_retries: git clone $url${RESET}"
        if $full_clone; then
            if git clone "$url" "$dest" >> "$LOG_FILE" 2>&1; then
                return 0
            fi
        else
            if git clone --depth=1 "$url" "$dest" >> "$LOG_FILE" 2>&1; then
                return 0
            fi
        fi
        ((retry++))
        if [ $retry -lt $max_retries ]; then
            warning "Reintentando clone... ($retry/$max_retries)"
            rm -rf "$dest" 2>/dev/null
            sleep 1
        fi
    done
    error "Falló git clone: $url"
    return 1
}

# Descargar archivo con reintentos
safe_download() {
    local url="$1"
    local dest="$2"
    local max_retries=3
    local retry=0
    
    while [ $retry -lt $max_retries ]; do
        echo -e "${DIM}  Intento $((retry+1))/$max_retries: descargando $(basename $dest)${RESET}"
        if wget -q --show-progress "$url" -O "$dest" 2>> "$LOG_FILE"; then
            [ -f "$dest" ] && [ -s "$dest" ] && return 0
        fi
        ((retry++))
        if [ $retry -lt $max_retries ]; then
            warning "Reintentando descarga... ($retry/$max_retries)"
            rm -f "$dest" 2>/dev/null
            sleep 1
        fi
    done
    error "Falló descarga: $url"
    return 1
}

# Ejecutar comando con reintentos
safe_exec() {
    local description="$1"
    shift
    local max_retries=3
    local retry=0
    
    while [ $retry -lt $max_retries ]; do
        echo -e "${DIM}  Intento $((retry+1))/$max_retries: $description${RESET}"
        if "$@" >> "$LOG_FILE" 2>&1; then
            return 0
        fi
        ((retry++))
        if [ $retry -lt $max_retries ]; then
            warning "Reintentando... ($retry/$max_retries)"
            sleep 1
        fi
    done
    error "Falló: $description"
    return 1
}

# Comprobar si el usuario actual es root
if [ "$UID" -eq 0 ]; then
    error "No se puede ejecutar como root."
    exit 1
else
    # Comprobar si se está usando sudo
    if [ -n "$SUDO_USER" ]; then
        error "No uses sudo"
        exit 1
    fi
fi

echo -e "${CYAN}"
echo "                                                     
@@@  @@@   @@@@@@   @@@       @@@  @@@@@@@   @@@  @@@  @@@  @@@@@@@@@@   
@@@  @@@  @@@@@@@@  @@@       @@@  @@@@@@@@  @@@  @@@  @@@  @@@@@@@@@@@  
@@!  !@@  @@!  @@@  @@!       @@!  @@!  @@@  @@!  @@!  @@!  @@! @@! @@!  
!@!  @!!  !@!  @!@  !@!       !@!  !@!  @!@  !@!  !@!  !@!  !@! !@! !@!  
@!@@!@!   @!@!@!@!  @!!       !!@  @!@@!@!   @!!  !!@  @!@  @!! !!@ @!@  
!!@!!!    !!!@!!!!  !!!       !!!  !!@!!!    !@!  !!!  !@!  !@!   ! !@!  
!!: :!!   !!:  !!!  !!:       !!:  !!:       !!:  !!:  !!:  !!:     !!:  
:!:  !:!  :!:  !:!   :!:      :!:  :!:       :!:  :!:  :!:  :!:     :!:  
 ::  :::  ::   :::   :: ::::   ::   ::        :::: :: :::   :::     ::   
 :   :::   :   : :  : :: : :  :     :          :: :  : :     :      :    
"
echo -e "${RESET}"
success "Script de automatización de entorno de hacking profesional."
info "@afsh4ck - Sígueme en: YouTube, Instagram, TikTok"
info "Log de instalación: $LOG_FILE"
echo ""
info "Configurando la instalación..."

RPATH=$(pwd)
EWW_READY=true

# ═══════════════════════════════════════════════════════════════════════════
# ACTUALIZACIÓN DEL SISTEMA
# ═══════════════════════════════════════════════════════════════════════════
start_step "Actualizar repositorios"
if sudo apt update >> "$LOG_FILE" 2>&1; then
    finish_step
else
    fail_step "No se pudo actualizar apt"
fi

# ═══════════════════════════════════════════════════════════════════════════
# INSTALACIÓN DE PAQUETES
# ═══════════════════════════════════════════════════════════════════════════
start_step "Instalar paquetes base"
if safe_install git bspwm vim feh scrot scrub zsh rofi xclip xsel locate wmname acpi sxhkd \
    imagemagick ranger kitty tmux python3-pip font-manager lsd bpython open-vm-tools-desktop open-vm-tools fastfetch \
    fd-find ripgrep tree ncdu htop libnotify-bin dos2unix pulseaudio-utils xdotool bluez blueman; then
    finish_step
else
    fail_step "Algunos paquetes no se instalaron"
fi

start_step "Instalar dependencias del entorno"
if safe_install build-essential libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev \
    libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev libasound2-dev libxcb-xtest0-dev libxcb-shape0-dev; then
    finish_step
else
    fail_step "Algunas dependencias no se instalaron"
fi

start_step "Instalar requisitos de polybar"
if safe_install cmake cmake-data pkg-config python3-sphinx libcairo2-dev libxcb1-dev libxcb-util0-dev \
    libxcb-randr0-dev libxcb-composite0-dev python3-xcbgen xcb-proto libxcb-image0-dev libxcb-ewmh-dev \
    libxcb-icccm4-dev libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev libpulse-dev libjsoncpp-dev \
    libmpdclient-dev libuv1-dev libnl-genl-3-dev libiw-dev libcurl4-openssl-dev; then
    finish_step
else
    fail_step "Algunas dependencias de polybar no se instalaron"
fi

start_step "Instalar dependencias de picom"
if safe_install meson ninja-build libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev \
    libxcb-render-util0-dev libxcb-render0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev \
    libxcb-xinerama0-dev libpixman-1-dev libdbus-1-dev libconfig-dev libgl1-mesa-dev libpcre2-dev libevdev-dev \
    uthash-dev libev-dev libx11-xcb-dev libxcb-glx0-dev libpcre3 libpcre3-dev libepoxy-dev; then
    finish_step
else
    fail_step "Algunas dependencias de picom no se instalaron"
fi

# Instalar Hack Nerd Font
start_step "Instalar Hack Nerd Font"
mkdir -p /tmp/fonts
if safe_download "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip" "/tmp/fonts/Hack.zip"; then
    unzip -q /tmp/fonts/Hack.zip -d /tmp/fonts
    mkdir -p ~/.local/share/fonts
    mv /tmp/fonts/*.ttf ~/.local/share/fonts/ 2>/dev/null
    rm -rf /tmp/fonts
    fc-cache -fv >> "$LOG_FILE" 2>&1
    finish_step
else
    fail_step "No se pudo descargar Hack Nerd Font"
fi

# Instalar JetBrains Mono Nerd Font
start_step "Instalar JetBrains Mono Nerd Font"
mkdir -p /tmp/fonts
if safe_download "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip" "/tmp/fonts/JetBrainsMono.zip"; then
    unzip -q /tmp/fonts/JetBrainsMono.zip -d /tmp/fonts
    mkdir -p ~/.local/share/fonts
    mv /tmp/fonts/*.ttf ~/.local/share/fonts/ 2>/dev/null
    rm -rf /tmp/fonts
    fc-cache -fv >> "$LOG_FILE" 2>&1
    finish_step
else
    fail_step "No se pudo descargar JetBrains Mono"
fi

# Instalar Iosevka Nerd Font
start_step "Instalar Iosevka Nerd Font"
mkdir -p /tmp/fonts
if safe_download "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Iosevka.zip" "/tmp/fonts/Iosevka.zip"; then
    unzip -q /tmp/fonts/Iosevka.zip -d /tmp/fonts
    mkdir -p ~/.local/share/fonts
    mv /tmp/fonts/*.ttf ~/.local/share/fonts/ 2>/dev/null
    rm -rf /tmp/fonts
    fc-cache -fv >> "$LOG_FILE" 2>&1
    finish_step
else
    fail_step "No se pudo descargar Iosevka Nerd Font"
fi

# Instalar ohmyzsh
start_step "Instalar Oh My Zsh"
rm -rf ~/.oh-my-zsh
if yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" >> "$LOG_FILE" 2>&1; then
    finish_step
else
    fail_step "No se pudo instalar Oh My Zsh"
fi

# Instalar powerlevel10k (en ~/powerlevel10k como espera el zshrc)
start_step "Instalar Powerlevel10k"
if safe_git_clone "https://github.com/romkatv/powerlevel10k.git" "$HOME/powerlevel10k"; then
    rm -f ~/.p10k.zsh
    cp -v $RPATH/CONFIGS/p10k.zsh ~/.p10k.zsh >> "$LOG_FILE" 2>&1
    finish_step
else
    fail_step "No se pudo instalar Powerlevel10k"
fi

# Instalar plugins de zsh (en /usr/share como espera el zshrc de Kali)
start_step "Instalar plugins de ZSH"
# zsh-autosuggestions ya viene en Kali, pero verificamos
if [ ! -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    sudo mkdir -p /usr/share/zsh-autosuggestions
    safe_git_clone "https://github.com/zsh-users/zsh-autosuggestions" "/tmp/zsh-autosuggestions"
    sudo cp /tmp/zsh-autosuggestions/zsh-autosuggestions.zsh /usr/share/zsh-autosuggestions/
    rm -rf /tmp/zsh-autosuggestions
fi
# zsh-syntax-highlighting ya viene en Kali, pero verificamos
if [ ! -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    sudo mkdir -p /usr/share/zsh-syntax-highlighting
    safe_git_clone "https://github.com/zsh-users/zsh-syntax-highlighting.git" "/tmp/zsh-syntax-highlighting"
    sudo cp -r /tmp/zsh-syntax-highlighting/* /usr/share/zsh-syntax-highlighting/
    rm -rf /tmp/zsh-syntax-highlighting
fi
finish_step

rm -f ~/.zshrc
cp -v $RPATH/CONFIGS/zshrc ~/.zshrc >> "$LOG_FILE" 2>&1

# Instalar fzf
start_step "Instalar FZF"
if safe_git_clone "https://github.com/junegunn/fzf.git" "$HOME/.fzf"; then
    yes | ~/.fzf/install >> "$LOG_FILE" 2>&1
    finish_step
else
    fail_step "No se pudo instalar FZF"
fi

# .tmux
start_step "Configurar TMUX"
rm -rf ~/.tmux
if safe_git_clone "https://github.com/gpakosz/.tmux.git" "$HOME/.tmux"; then
    ln -s -f ~/.tmux/.tmux.conf ~/
    cp -v $RPATH/CONFIGS/tmux.conf.local ~/.tmux.conf.local >> "$LOG_FILE" 2>&1
    finish_step
else
    fail_step "No se pudo configurar tmux"
fi

# nvim
start_step "Instalar Neovim"
if safe_download "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz" "/tmp/nvim-linux64.tar.gz"; then
    sudo tar xzvf /tmp/nvim-linux64.tar.gz --directory=/opt >> "$LOG_FILE" 2>&1
    sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/bin/nvim
    sudo rm -f /tmp/nvim-linux64.tar.gz
    finish_step
else
    fail_step "No se pudo descargar Neovim"
fi

# Instalar terminal kitty
start_step "Instalar Kitty terminal"
if cat $RPATH/kitty-installer.sh | sh /dev/stdin >> "$LOG_FILE" 2>&1; then
    finish_step
else
    fail_step "No se pudo instalar Kitty"
fi

# batcat
start_step "Instalar batcat"
safe_install bat && finish_step || fail_step "No se pudo instalar bat"

# Clonar repositorios de polybar & picom (oficial con animaciones v12+)
start_step "Clonar repositorios (polybar, picom)"
mkdir -p ~/github
safe_git_clone "https://github.com/polybar/polybar" "$HOME/github/polybar" --full
safe_git_clone "https://github.com/yshui/picom.git" "$HOME/github/picom" --full
finish_step

# Instalar polybar
start_step "Compilar e instalar Polybar"
cd ~/github/polybar
git submodule update --init --recursive >> "$LOG_FILE" 2>&1
mkdir -p build
cd build
if cmake .. >> "$LOG_FILE" 2>&1 && make -j$(nproc) >> "$LOG_FILE" 2>&1 && sudo make install >> "$LOG_FILE" 2>&1; then
    finish_step
else
    fail_step "Error compilando Polybar (ver: $LOG_FILE)"
fi

# Instalar picom oficial (v12+ con animaciones nativas)
start_step "Compilar e instalar Picom (animaciones)"
cd ~/github/picom
git submodule update --init --recursive >> "$LOG_FILE" 2>&1
# Limpiar build anterior si existe
rm -rf build 2>/dev/null
if meson setup --buildtype=release build >> "$LOG_FILE" 2>&1 && ninja -C build >> "$LOG_FILE" 2>&1 && sudo ninja -C build install >> "$LOG_FILE" 2>&1; then
    finish_step
else
    fail_step "Error compilando Picom (ver: $LOG_FILE)"
fi

# Instalar cava (visualizador de audio)
start_step "Instalar CAVA"
safe_install cava && finish_step || fail_step "No se pudo instalar CAVA"

# Instalar dependencias de eww (completas para X11)
start_step "Instalar dependencias de EWW"
if safe_install libgtk-3-dev libpango1.0-dev libgdk-pixbuf-2.0-dev libcairo2-dev libglib2.0-dev \
    libatk1.0-dev pkg-config librsvg2-dev libssl-dev libx11-dev libxext-dev libxrandr-dev \
    libxinerama-dev libxi-dev libxcursor-dev libxfixes-dev; then
    # Dependencias opcionales (pueden no existir en algunas versiones de Kali)
    if ! safe_install libgtk-layer-shell-dev libdbusmenu-gtk3-dev libdbusmenu-glib-dev \
        gobject-introspection libgirepository1.0-dev; then
        warning "Algunas dependencias opcionales de EWW no están disponibles; se continúa con X11"
    fi

    # Verificación clave para evitar fallo de gdk-sys en cargo
    if pkg-config --exists gdk-3.0 >> "$LOG_FILE" 2>&1; then
        pkg-config --modversion gdk-3.0 >> "$LOG_FILE" 2>&1
        finish_step
    else
        EWW_READY=false
        fail_step "No se detecta gdk-3.0 (pkg-config). Revisa libgtk-3-dev y pkg-config"
    fi
else
    EWW_READY=false
    fail_step "Dependencias críticas de EWW incompletas"
fi

# Instalar Rust (necesario para eww)
start_step "Instalar Rust"
if command_exists rustc; then
    info "Rust ya está instalado, actualizando..."
    source "$HOME/.cargo/env" 2>/dev/null
    rustup update >> "$LOG_FILE" 2>&1
    finish_step
elif curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y >> "$LOG_FILE" 2>&1; then
    source "$HOME/.cargo/env"
    finish_step
else
    fail_step "No se pudo instalar Rust"
fi

# Instalar eww (ElKowar's Wacky Widgets)
start_step "Compilar e instalar EWW"
if [ "$EWW_READY" != true ]; then
    fail_step "Saltado: faltan dependencias GTK (gdk-3.0 no disponible)"
elif safe_git_clone "https://github.com/elkowar/eww" "$HOME/github/eww" --full; then
    cd ~/github/eww
    # Asegurar que cargo está disponible
    source "$HOME/.cargo/env" 2>/dev/null || true
    export PATH="$HOME/.cargo/bin:$PATH"
    
    # Compilar para X11
    info "Compilando EWW (esto puede tardar varios minutos)..."
    if cargo build --release --no-default-features --features x11 >> "$LOG_FILE" 2>&1; then
        sudo cp target/release/eww /usr/local/bin/
        chmod +x /usr/local/bin/eww
        # Copiar configuración de EWW
        mkdir -p ~/.config/eww
        cp -r $RPATH/CONFIGS/config/eww/* ~/.config/eww/
        finish_step
    else
        fail_step "Error compilando EWW (ver: $LOG_FILE)"
    fi
else
    fail_step "No se pudo clonar EWW"
fi

# Dependencias para clipmenu
start_step "Instalar clipmenu"
if safe_install libxfixes-dev; then
    cd /tmp
    rm -rf clipmenu
    if safe_git_clone "https://github.com/cdown/clipmenu" "/tmp/clipmenu"; then
        cd clipmenu
        sudo make install >> "$LOG_FILE" 2>&1
        cd ..
        rm -rf clipmenu
        finish_step
    else
        fail_step "No se pudo clonar clipmenu"
    fi
else
    fail_step "No se pudieron instalar dependencias de clipmenu"
fi

# ghidra
start_step "Instalar herramientas adicionales"
safe_install ghidra flameshot playerctl pamixer && finish_step || fail_step "Algunas herramientas no se instalaron"

# Cambiar zona horaria, para listar zonas horarias ejecutar: timedatectl list-timezones
start_step "Configurar sistema"
sudo timedatectl set-timezone "America/Argentina/Buenos_Aires" >> "$LOG_FILE" 2>&1

# Cambiar el layout del teclado
sudo bash -c 'echo "# KEYBOARD CONFIGURATION FILE

# Consult the keyboard(5) manual page.

XKBMODEL=\"pc105\"
XKBLAYOUT=\"latam\"
XKBVARIANT=\"\"
XKBOPTIONS=\"\"

BACKSPACE=\"guess\"" > /etc/default/keyboard'
finish_step

# Copiar todos los archivos de configuración
start_step "Copiar configuraciones"
cp -rv $RPATH/CONFIGS/config/* ~/.config/ >> "$LOG_FILE" 2>&1

# Copiar scripts
mkdir -p ~/.config/scripts
cp -rv $RPATH/SCRIPTS/* ~/.config/scripts/ >> "$LOG_FILE" 2>&1

# Copiar wallpapers
mkdir -p ~/Wallpapers/
cp -rv $RPATH/WALLPAPERS/* ~/Wallpapers/ >> "$LOG_FILE" 2>&1

# Crear directorio de screenshots
mkdir -p ~/screenshots/
finish_step

# Establecer permisos de ejecución
start_step "Establecer permisos"
chmod +x ~/.config/bspwm/bspwmrc
chmod +x ~/.config/bspwm/scripts/bspwm_resize
chmod +x ~/.config/polybar/launch.sh
chmod +x ~/.config/polybar/scripts/*
chmod +x ~/.config/scripts/*
chmod +x ~/.config/eww/*.sh 2>/dev/null || true
chmod +x ~/.config/eww/music-widget/*.sh 2>/dev/null || true

# Normalizar finales de línea (evita fallos al editar/copiar desde Windows)
find ~/.config/eww ~/.config/polybar ~/.config/scripts -type f \( \
    -name "*.sh" -o -name "*.conf" -o -name "*.ini" -o -name "*.rasi" -o -name "*.yuck" -o -name "*.scss" -o -name "*.rc" \
\) -exec dos2unix {} + >> "$LOG_FILE" 2>&1 || true

# Limpiar cache de EWW para evitar usar CSS/estado roto de ejecuciones previas
rm -rf ~/.cache/eww 2>/dev/null || true
finish_step

# Crear script para lanzar eww
cat > ~/.config/scripts/eww-toggle.sh << 'EOF'
#!/bin/bash
# Toggle sidebar de eww
STATE=$(eww state | grep -c "sidebar")
if eww windows | grep -q "\*sidebar"; then
    eww close sidebar
else
    eww open sidebar
fi
EOF
chmod +x ~/.config/scripts/eww-toggle.sh

# ═══════════════════════════════════════════════════════════════════════════
# REPORTE FINAL
# ═══════════════════════════════════════════════════════════════════════════

echo ""
echo ""
show_progress $TOTAL_STEPS $TOTAL_STEPS "Instalación completada"
echo ""
echo ""

# Mostrar resumen de errores si los hubo
if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${YELLOW}║${RESET}              ${BOLD}⚠️  INSTALACIÓN COMPLETADA CON ERRORES${RESET}                     ${YELLOW}║${RESET}"
    echo -e "${YELLOW}╠══════════════════════════════════════════════════════════════════════════╣${RESET}"
    echo -e "${YELLOW}║${RESET}                                                                          ${YELLOW}║${RESET}"
    echo -e "${YELLOW}║${RESET}  ${RED}Pasos que fallaron (${#FAILED_STEPS[@]}):${RESET}                                           ${YELLOW}║${RESET}"
    for step in "${FAILED_STEPS[@]}"; do
        echo -e "${YELLOW}║${RESET}    ${RED}✗${RESET} $step"
    done
    echo -e "${YELLOW}║${RESET}                                                                          ${YELLOW}║${RESET}"
    echo -e "${YELLOW}║${RESET}  ${CYAN}📋 Log completo: ${LOG_FILE}${RESET}"
    echo -e "${YELLOW}║${RESET}                                                                          ${YELLOW}║${RESET}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════════════════╝${RESET}"
else
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║${RESET}              ${BOLD}✅ INSTALACIÓN COMPLETADA EXITOSAMENTE${RESET}                     ${GREEN}║${RESET}"
    echo -e "${GREEN}╠══════════════════════════════════════════════════════════════════════════╣${RESET}"
    echo -e "${GREEN}║${RESET}                                                                          ${GREEN}║${RESET}"
fi

echo -e "${GREEN}║${RESET}  ${CYAN}📚 Comandos útiles:${RESET}                                                    ${GREEN}║${RESET}"
echo -e "${GREEN}║${RESET}     ${YELLOW}help${RESET} / ${YELLOW}cheat${RESET}    - Ver cheatsheet de atajos                        ${GREEN}║${RESET}"
echo -e "${GREEN}║${RESET}     ${YELLOW}welcome${RESET}          - Mostrar banner de bienvenida                    ${GREEN}║${RESET}"
echo -e "${GREEN}║${RESET}     ${YELLOW}cc${RESET}               - Clear con animación                             ${GREEN}║${RESET}"
echo -e "${GREEN}║${RESET}     ${YELLOW}sysinfo${RESET}          - Info del sistema                                ${GREEN}║${RESET}"
echo -e "${GREEN}║${RESET}                                                                          ${GREEN}║${RESET}"
echo -e "${GREEN}║${RESET}  ${CYAN}⌨️  Atajos de EWW:${RESET}                                                      ${GREEN}║${RESET}"
echo -e "${GREEN}║${RESET}     ${YELLOW}Super+Shift+W${RESET}    - Toggle sidebar (música + sistema)               ${GREEN}║${RESET}"
echo -e "${GREEN}║${RESET}     ${YELLOW}Super+Shift+M${RESET}    - Toggle solo música                              ${GREEN}║${RESET}"
echo -e "${GREEN}║${RESET}                                                                          ${GREEN}║${RESET}"
echo -e "${GREEN}║${RESET}  ${CYAN}📋 Log de instalación:${RESET} ${DIM}$LOG_FILE${RESET}"
echo -e "${GREEN}║${RESET}                                                                          ${GREEN}║${RESET}"
echo -e "${GREEN}║${RESET}  ${RED}⚠️  IMPORTANTE: Reinicia el equipo para aplicar cambios${RESET}                 ${GREEN}║${RESET}"
echo -e "${GREEN}║${RESET}                                                                          ${GREEN}║${RESET}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════╝${RESET}"
echo ""
success "Happy Hacking! 🐱‍💻"
echo ""
warning "Ejecuta: sudo reboot"
echo ""