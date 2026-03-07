
# EWW Bar adaptada para KaliPWM (BSPWM)

Esta carpeta quedó adaptada para tu rice en Kali + BSPWM.

## Qué trae esta adaptación

- Barra compatible con BSPWM (sin `hyprctl`).
- Módulo `target` para mostrar la IP/objetivo de `~/.config/scripts/target`.
- Checker de updates para `apt` (Kali/Debian), no `paru/checkupdates`.
- Paleta visual estilo KaliPWM (neón cian/fucsia, fondo oscuro).
- Script de despliegue automático: `setup-kali-bar.sh`.

## 1) Dependencias

Desde esta carpeta:

```bash
cd ~/Documents/entornos/kalipwm/eww
sudo apt update
xargs -a dependencies-kali.lst sudo apt install -y
```

Si todavía no tienes `eww`, puedes instalarlo desde tu `kalipwm.sh` o compilarlo con Rust como en el instalador principal del repo.

## 2) Deploy de la barra

```bash
cd ~/Documents/entornos/kalipwm/eww
chmod +x setup-kali-bar.sh
./setup-kali-bar.sh
```

El script hace:

- Backup de `~/.config/eww` si ya existe.
- Copia `eww/` a `~/.config/eww`.
- Copia `end-rs/` a `~/.config/end-rs`.
- Aplica permisos de ejecución.
- Reinicia daemon de `eww` y abre ventanas principales.

## 3) Levantar manualmente (alternativa)

```bash
pkill -x eww || true
rm -rf ~/.cache/eww
eww daemon
pkill -f end-rs || true
~/.config/eww/bin/end-rs &
eww open eww-bar
eww open bg-panel
eww open activate-linux
```

## 4) Integración recomendada en BSPWM

En tu `~/.config/bspwm/bspwmrc`, agrega algo como:

```bash
pkill -x eww || true
eww daemon
pkill -f end-rs || true
~/.config/eww/bin/end-rs &
eww open eww-bar
eww open bg-panel
eww open activate-linux
```

## 5) Troubleshooting rápido

- Si no aparecen workspaces: verifica que `bspwm` esté corriendo y `bspc` exista en PATH.
- Si no aparecen updates: ejecuta `apt list --upgradable` para validar salida.
- Si no sale el target: crea el archivo `~/.config/scripts/target` con una IP o hostname.
- Si se ve rota la UI: borra cache y relanza `eww`.

```bash
rm -rf ~/.cache/eww && pkill -x eww && eww daemon && eww open eww-bar
```
