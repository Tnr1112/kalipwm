#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config/eww.backup.$(date +%Y%m%d_%H%M%S)"

info() { echo "[+] $1"; }
warn() { echo "[!] $1"; }

info "Copiando configuración EWW adaptada para KaliPWM..."

if [[ -d "$HOME/.config/eww" ]]; then
  mkdir -p "$BACKUP_DIR"
  cp -a "$HOME/.config/eww/." "$BACKUP_DIR/"
  info "Backup creado en: $BACKUP_DIR"
fi

mkdir -p "$HOME/.config/eww"
cp -a "$ROOT_DIR/eww/." "$HOME/.config/eww/"

mkdir -p "$HOME/.config/end-rs"
cp -a "$ROOT_DIR/end-rs/." "$HOME/.config/end-rs/"

find "$HOME/.config/eww" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} +
chmod +x "$HOME/.config/eww/bin/end-rs" 2>/dev/null || true

if command -v dos2unix >/dev/null 2>&1; then
  find "$HOME/.config/eww" -type f \( -name "*.sh" -o -name "*.yuck" -o -name "*.scss" \) -exec dos2unix {} + >/dev/null 2>&1 || true
fi

info "Reiniciando daemon de EWW..."
pkill -x eww >/dev/null 2>&1 || true
rm -rf "$HOME/.cache/eww" >/dev/null 2>&1 || true

if command -v eww >/dev/null 2>&1; then
  eww daemon
else
  warn "No se encontró 'eww' en PATH. Instálalo primero."
  exit 1
fi

pkill -f end-rs >/dev/null 2>&1 || true
"$HOME/.config/eww/bin/end-rs" >/dev/null 2>&1 &

eww open eww-bar
eww open bg-panel
eww open activate-linux

info "Listo. Barra levantada con perfil KaliPWM."
