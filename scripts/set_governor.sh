#!/usr/bin/env bash
# Define o governor de CPU (performance | powersave) em todos os núcleos
mode="$1"
case "$mode" in
  performance|powersave) ;;
  *) echo "Uso: $0 performance|powersave" >&2; exit 1 ;;
esac
for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  echo "$mode" > "$f"
done
