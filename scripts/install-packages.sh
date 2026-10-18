#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="check"
INCLUDE_OPTIONAL=0

usage() {
    cat <<'USAGE'
Usage:
  ./scripts/install-packages.sh
  ./scripts/install-packages.sh --check
  ./scripts/install-packages.sh --install
  ./scripts/install-packages.sh --install --include-optional

Default: check only; no system changes.
USAGE
}

for arg in "$@"; do
    case "$arg" in
        --check) MODE="check" ;;
        --install) MODE="install" ;;
        --include-optional) INCLUDE_OPTIONAL=1 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown argument: $arg"; usage; exit 2 ;;
    esac
done

if [[ "$INCLUDE_OPTIONAL" -eq 1 && "$MODE" != "install" ]]; then
    echo "Use --include-optional together with --install."
    exit 2
fi

if ! command -v pacman >/dev/null 2>&1; then
    echo "Error: pacman was not found. This script targets Arch-based systems."
    exit 1
fi

files=(
    "$REPO_DIR/packages/base.txt"
    "$REPO_DIR/packages/desktop.txt"
)

if [[ "$INCLUDE_OPTIONAL" -eq 1 ]]; then
    files+=("$REPO_DIR/packages/optional.txt")
fi

for file in "${files[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo "Error: package list not found: $file"
        exit 1
    fi
done

declare -A seen=()
packages=()

for file in "${files[@]}"; do
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Remove surrounding whitespace.
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"

        [[ -z "$line" || "$line" == \#* ]] && continue

        if [[ ! "$line" =~ ^[a-zA-Z0-9@._+-]+$ ]]; then
            echo "Error: invalid package entry in $file: $line"
            exit 1
        fi

        if [[ -z "${seen[$line]+x}" ]]; then
            seen["$line"]=1
            packages+=("$line")
        fi
    done < "$file"
done

if [[ "${#packages[@]}" -eq 0 ]]; then
    echo "No packages found in the selected lists."
    exit 0
fi

installed=()
to_install=()
unavailable=()

echo "Mode: $MODE"
echo "Optional packages: $([[ "$INCLUDE_OPTIONAL" -eq 1 ]] && echo included || echo excluded)"
echo

for pkg in "${packages[@]}"; do
    if pacman -Qq "$pkg" >/dev/null 2>&1; then
        printf '[INSTALLED]  %s\n' "$pkg"
    elif pacman -Si "$pkg" >/dev/null 2>&1; then
        printf '[AVAILABLE]  %s\n' "$pkg"
        to_install+=("$pkg")
    else
        printf '[UNAVAILABLE] %s\n' "$pkg"
        unavailable+=("$pkg")
    fi
done

echo
echo "Already installed: $((${#packages[@]} - ${#to_install[@]} - ${#unavailable[@]}))"
echo "To install:        ${#to_install[@]}"
echo "Unavailable:       ${#unavailable[@]}"

if [[ "${#unavailable[@]}" -gt 0 ]]; then
    echo "Resolve unavailable packages before installation."
    exit 1
fi

if [[ "$MODE" == "check" ]]; then
    echo "Check complete. No system changes were made."
    exit 0
fi

if [[ "${#to_install[@]}" -eq 0 ]]; then
    echo "All selected packages are already installed."
    exit 0
fi

echo
echo "Packages to install:"
printf '  %s\n' "${to_install[@]}"
echo
read -r -p "Install these packages using pacman? [y/N] " answer

if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
    echo "Cancelled. No packages were installed."
    exit 0
fi

sudo pacman -S --needed -- "${to_install[@]}"

echo "Package installation finished."
