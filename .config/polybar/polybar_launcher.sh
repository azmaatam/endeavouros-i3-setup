#!/usr/bin/env bash
set -Eeuo pipefail

if ! command -v polybar >/dev/null 2>&1; then
    exit 0
fi

BAR_NAME="i3wmthemer_bar"

if command -v xrandr >/dev/null 2>&1; then
    mapfile -t monitors < <(
        xrandr --query |
        awk '/ connected/ {print $1}'
    )
else
    monitors=()
fi

# Stop only instances of this bar; leave other Polybar bars untouched.
while IFS= read -r pid; do
    [[ -n "$pid" ]] || continue
    args=$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null || true)
    if [[ "$args" == *"polybar"* && "$args" == *"$BAR_NAME"* ]]; then
        kill "$pid" 2>/dev/null || true
    fi
done < <(pgrep -x polybar || true)

sleep 1

if [[ "${#monitors[@]}" -gt 0 ]]; then
    for monitor in "${monitors[@]}"; do
        MONITOR="$monitor" polybar --reload "$BAR_NAME" &
    done
else
    polybar --reload "$BAR_NAME" &
fi
