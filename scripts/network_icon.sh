#!/usr/bin/env bash
# Imprime ícone conforme nível do sinal wifi + %
iface=$(nmcli -t -f DEVICE,TYPE,STATE device | awk -F: '$2=="wifi" && $3=="connected" {print $1; exit}')
if [ -z "$iface" ]; then
  eth=$(nmcli -t -f DEVICE,TYPE,STATE device | awk -F: '$2=="ethernet" && $3=="connected" {print $1; exit}')
  if [ -n "$eth" ]; then
    echo '{"text":"\uf0ac","class":"ethernet"}'
  else
    echo '{"text":"󰤯","class":"disconnected"}'
  fi
  exit 0
fi
signal=$(nmcli -t -f IN-USE,SIGNAL device wifi list 2>/dev/null | awk -F: '$1=="*" {print $2; exit}')
[ -z "$signal" ] && signal=0
if [ "$signal" -ge 75 ]; then
  icon="󰤨"
elif [ "$signal" -ge 50 ]; then
  icon="󰤥"
elif [ "$signal" -ge 25 ]; then
  icon="󰤢"
else
  icon="󰤟"
fi
echo "{\"text\":\"$icon  ${signal}%\",\"class\":\"wifi\"}"
