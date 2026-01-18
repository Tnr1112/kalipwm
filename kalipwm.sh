#!/bin/bash

# Comprobar si el usuario actual es root
if [ "$UID" -eq 0 ]; then
    echo "No se puede ejecutar como root."
    exit 1
else
    # Comprobar si se está usando sudo
    if [ -n "$SUDO_USER" ]; then
        echo "No uses sudo"
        exit 1
    fi
fi

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
sleep 2
echo -e "[+] Script de automatización de entorno de hacking profesional."
echo -e "[+] @afsh4ck - Sígueme en: YouTube, Instagram, TikTok"
sleep 3
echo -e "\n[*] Configurando la instalación..\n"
sleep 4

RPATH=`pwd`

# Actualizar paquetes
sudo apt update

# Instalar paquetes
sudo apt install -y git bspwm vim feh scrot scrub zsh rofi xclip xsel locate wmname acpi sxhkd \
    imagemagick ranger kitty tmux python3-pip font-manager lsd bpython open-vm-tools-desktop open-vm-tools fastfetch # (neofetch obsoleto)

# Instalar dependencias del entorno
sudo apt install -y build-essential libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev \
    libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev libasound2-dev libxcb-xtest0-dev libxcb-shape0-dev # (xcb eliminado)

# Instalar requisitos de polybar
sudo apt install -y cmake cmake-data pkg-config python3-sphinx libcairo2-dev libxcb1-dev libxcb-util0-dev \
    libxcb-randr0-dev libxcb-composite0-dev python3-xcbgen xcb-proto libxcb-image0-dev libxcb-ewmh-dev \
    libxcb-icccm4-dev libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev libpulse-dev libjsoncpp-dev \
    libmpdclient-dev libuv1-dev libnl-genl-3-dev

# Instalar dependencias de picom
sudo apt install -y meson libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev \
    libxcb-render-util0-dev libxcb-render0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev \
    libxcb-xinerama0-dev libpixman-1-dev libdbus-1-dev libconfig-dev libgl1-mesa-dev libpcre2-dev libevdev-dev \
    uthash-dev libev-dev libx11-xcb-dev libxcb-glx0-dev libpcre3 libpcre3-dev

# Instalar Hack Nerd Font
mkdir -p /tmp/fonts
wget -q --show-progress https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip -O /tmp/fonts/Hack.zip
unzip -q /tmp/fonts/Hack.zip -d /tmp/fonts
mkdir -p ~/.local/share/fonts
mv /tmp/fonts/*.ttf ~/.local/share/fonts/
rm -rf /tmp/fonts
fc-cache -fv

# Instalar JetBrains Mono Nerd Font
mkdir -p /tmp/fonts
wget -q --show-progress https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip -O /tmp/fonts/JetBrainsMono.zip
unzip -q /tmp/fonts/JetBrainsMono.zip -d /tmp/fonts
mv /tmp/fonts/*.ttf ~/.local/share/fonts/
rm -rf /tmp/fonts
fc-cache -fv

# Instalar ohmyzsh
rm -rf ~/.oh-my-zsh
yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Instalar powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
rm -f ~/.p10k.zsh
cp -v $RPATH/CONFIGS/p10k.zsh ~/.p10k.zsh

# Instalar plugins de zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
rm -f ~/.zshrc
# ¿Instalar zsh-autocomplete?
cp -v $RPATH/CONFIGS/zshrc ~/.zshrc

# Instalar fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
yes | ~/.fzf/install

# .tmux
rm -rf ~/.tmux
git clone https://github.com/gpakosz/.tmux.git ~/.tmux
ln -s -f ~/.tmux/.tmux.conf ~/
cp -v $RPATH/CONFIGS/tmux.conf.local ~/.tmux.conf.local

# nvim
wget -q --show-progress https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz -O /tmp/nvim-linux64.tar.gz
sudo tar xzvf /tmp/nvim-linux64.tar.gz --directory=/opt
sudo ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/bin/nvim
sudo rm -f /opt/nvim-linux64.tar.gz

# Instalar terminal kitty
cat $RPATH/kitty-installer.sh | sh /dev/stdin
# ~/.local/kitty.app/bin/kitty

# batcat
sudo apt install bat

# Clonar repositorios de polybar & picom (oficial con animaciones v12+)
mkdir ~/github
git clone --recursive https://github.com/polybar/polybar ~/github/polybar
git clone https://github.com/yshui/picom.git ~/github/picom

# Instalar polybar
cd ~/github/polybar
mkdir build
cd build
cmake ..
make -j$(nproc)
sudo make install

# Instalar temas de polybar
# git clone --depth=1 https://github.com/adi1090x/polybar-themes.git ~/github/polybar-themes
# chmod +x ~/github/polybar-themes/setup.sh
# cd ~/github/polybar-themes
# echo 1 | ./setup.sh

# Instalar picom oficial (v12+ con animaciones nativas)
cd ~/github/picom
git submodule update --init --recursive
meson setup --buildtype=release build
ninja -C build
sudo ninja -C build install

# Instalar cava (visualizador de audio)
sudo apt install -y cava

# Instalar dependencias de eww
sudo apt install -y libgtk-3-dev libpango1.0-dev libgdk-pixbuf-2.0-dev libcairo2-dev libglib2.0-dev

# Instalar Rust (necesario para eww)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

# Instalar eww (ElKowar's Wacky Widgets)
git clone https://github.com/elkowar/eww ~/github/eww
cd ~/github/eww
cargo build --release --no-default-features --features x11
sudo cp target/release/eww /usr/local/bin/

# Dependencias para clipmenu
sudo apt install -y libxfixes-dev

# clipmenu
git clone https://github.com/cdown/clipmenu
cd clipmenu
sudo make install
cd ..
rm -rf clipmenu

# ghidra
sudo apt install -y ghidra

# flameshot
sudo apt install -y flameshot

# Cambiar zona horaria, para listar zonas horarias ejecutar: timedatectl list-timezones
sudo timedatectl set-timezone "America/Argentina/Buenos_Aires"

# Cambiar el layout del teclado
sudo bash -c 'echo "# KEYBOARD CONFIGURATION FILE

# Consult the keyboard(5) manual page.

XKBMODEL=\"pc105\"
XKBLAYOUT=\"latam\"
XKBVARIANT=\"\"
XKBOPTIONS=\"\"

BACKSPACE=\"guess\"" > /etc/default/keyboard'

# Copiar todos los archivos de configuración
cp -rv $RPATH/CONFIGS/config/* ~/.config/

# Copiar scripts
mkdir -p ~/.config/scripts
cp -rv $RPATH/SCRIPTS/* ~/.config/scripts/

# Copiar wallpapers
mkdir ~/Wallpapers/
cp -rv $RPATH/WALLPAPERS/* ~/Wallpapers/

# Establecer permisos de ejecución
chmod +x ~/.config/bspwm/bspwmrc
chmod +x ~/.config/bspwm/scripts/bspwm_resize
chmod +x ~/.config/polybar/launch.sh
chmod +x ~/.config/scripts/*

# Instalar playerctl para control de música (necesario para eww)
sudo apt install -y playerctl

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

# Seleccionar tema de rofi
# rofi-theme-selector

# Limpiar archivos
# rm -rf ~/github
# rm -rf $RPATH
# sudo apt autoremove -y

echo -e "\n[+] Entorno desplegado, Happy Hacking ;) \n"
echo -e "\n[+] Por favor, reinicia el equipo (sudo reboot) \n"
