#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
MODE="dry-run"
targets=(i3 polybar picom rofi kitty)

usage() {
    cat <<'USAGE'
Usage:
  ./scripts/install-dotfiles.sh [--dry-run|--install|--help]

Default: --dry-run
--install adds missing files only. Existing files are never overwritten.
USAGE
}

case "${1:---dry-run}" in
    --dry-run) MODE="dry-run" ;;
    --install) MODE="install" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1"; usage; exit 2 ;;
esac

for target in "${targets[@]}"; do
    [[ -d "$REPO_DIR/.config/$target" ]] || {
        echo "Error: missing source .config/$target" >&2
        exit 1
    }
done

echo "Mode: $MODE"
echo "Destination: $CONFIG_HOME"
echo "Policy: add missing files; never overwrite existing paths."
echo

conflicts=0
for target in "${targets[@]}"; do
    source="$REPO_DIR/.config/$target"
    destination="$CONFIG_HOME/$target"

    echo "[$target]"
    if [[ ! -e "$destination" ]]; then
        echo "  Destination does not exist; files can be added."
        continue
    fi

    while IFS= read -r -d '' src; do
        rel="${src#"$source"/}"
        dst="$destination/$rel"

        if [[ -e "$dst" || -L "$dst" ]]; then
            if [[ -f "$src" && -f "$dst" ]] && cmp -s -- "$src" "$dst"; then
                echo "  [SAME]   $rel"
            else
                echo "  [SKIP]   $rel (destination already exists)"
                conflicts=$((conflicts + 1))
            fi
        fi
    done < <(find "$source" -mindepth 1 -type f -print0)
done

echo
echo "Existing-path conflicts: $conflicts"

if [[ "$MODE" == "dry-run" ]]; then
    echo "Dry-run complete. No files were changed."
    exit 0
fi

read -r -p "Add missing files only? Existing paths will be preserved. [y/N] " answer
if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
    echo "Cancelled. No files were changed."
    exit 0
fi

"$REPO_DIR/scripts/backup-configs.sh"

mkdir -p -- "$CONFIG_HOME"
for target in "${targets[@]}"; do
    source="$REPO_DIR/.config/$target"
    destination="$CONFIG_HOME/$target"
    mkdir -p -- "$destination"
    cp -an -- "$source/." "$destination/"
    echo "[PROCESSED] $target"
done

echo
echo "Finished. Existing paths were preserved."
echo "Review the installed configuration before reloading i3."
