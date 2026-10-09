#!/usr/bin/env bash

## Author: Caio Muller (kalice)
## GitHub: @CaioMuller-dev

# Alterna o rádio Bluetooth pelo BlueZ. O clique direito abre o Blueman.
if ! command -v bluetoothctl >/dev/null 2>&1; then
    notify-send "Bluetooth" "O comando bluetoothctl não está instalado."
    exit 1
fi

status=$(bluetoothctl show 2>/dev/null) || status=""
powered=$(awk -F ': ' '/Powered:/ { print $2; exit }' <<< "$status")

case "$powered" in
    yes) action=off ;;
    no)  action=on ;;
    *)
        notify-send "Bluetooth" "Não foi possível consultar o adaptador Bluetooth."
        exit 1
        ;;
esac

if ! bluetoothctl power "$action" >/dev/null 2>&1; then
    notify-send "Bluetooth" "Falha ao desligar/ligar o Bluetooth. Verifique se o serviço bluetooth está ativo."
    exit 1
fi
