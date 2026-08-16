#!/usr/bin/env bash

# 1. Guardar el estado actual del portapapeles
clip_before=$(xclip -o -selection clipboard 2>/dev/null | md5sum)

# 2. Abrir el menú de Clipcat
clipcat-menu

# 3. Guardar el estado posterior a la interacción
clip_after=$(xclip -o -selection clipboard 2>/dev/null | md5sum)

# 4. Si el portapapeles no cambió (se canceló con Esc o cerró), salir
if [ "$clip_before" = "$clip_after" ]; then
    exit 0
fi

# 5. Breve espera para que la ventana destino recupere el foco tras cerrar Rofi
sleep 0.08

# 6. Detectar la clase de ventana y enviar el atajo correspondiente
active_window=$(xdotool getactivewindow 2>/dev/null)
window_class=$(xprop -id "$active_window" WM_CLASS 2>/dev/null | awk -F'"' '{print $4}')

case "$window_class" in
    "Alacritty"|"kitty"|"URxvt"|"XTerm")
        xdotool key --clearmodifiers ctrl+shift+v
        ;;
    *)
        xdotool key --clearmodifiers ctrl+v
        ;;
esac