#!/usr/bin/env bash
set -Eeuo pipefail

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_ROOT="$HOME/.local/state/endeavouros-i3-setup/backups"
TIMESTAMP="$(date +%Y%m%d-%H%M%S-%N)"
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"

targets=(
    i3
    polybar
    picom
    rofi
    kitty
)

found=0

for target in "${targets[@]}"; do
    if [[ -e "$CONFIG_HOME/$target" ]]; then
        found=1
        break
    fi
done

if [[ "$found" -eq 0 ]]; then
    echo "No existing target configurations found. Nothing to back up."
    exit 0
fi

mkdir -p "$BACKUP_DIR"

for target in "${targets[@]}"; do
    source="$CONFIG_HOME/$target"

    if [[ -e "$source" ]]; then
        cp -a -- "$source" "$BACKUP_DIR/"
        echo "[BACKED UP] $source"
    fi
done

echo
echo "Backup saved to: $BACKUP_DIR"
