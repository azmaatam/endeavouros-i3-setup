#!/usr/bin/env bash

icon_on="%{T2}%{T-}"
icon_off=""

powered=$(bluetoothctl show | grep "Powered" | awk '{print $2}')

if [[ "$powered" == "yes" ]]; then
    connected=$(bluetoothctl devices Connected | wc -l)
    if [[ $connected -gt 0 ]]; then
        echo "$icon_on Connected"
    else
        echo "$icon_on On"
    fi
else
    echo "$icon_on Off"
fi

