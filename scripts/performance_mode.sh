#!/usr/bin/env bash

## Author: Caio Muller (kalice)
## GitHub: @CaioMuller-dev

# Módulo waybar: mostra o governor atual e alterna ao clicar (on-click chama toggle)
current=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
case "$1" in
  toggle)
    if [ "$current" = "performance" ]; then
      sudo "$SCRIPT_DIR/set_governor.sh" powersave
    else
      sudo "$SCRIPT_DIR/set_governor.sh" performance
    fi
    exit 0
    ;;
esac
if [ "$current" = "performance" ]; then
  echo '{"text":"","class":"performance","tooltip":"Performance (clique para economia)"}'
else
  echo '{"text":"\uf06c","class":"powersave","tooltip":"Powersave (clique para desempenho)"}'
fi
