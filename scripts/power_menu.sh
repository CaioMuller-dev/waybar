#!/usr/bin/env bash

## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x
#
## Rofi   : Power Menu
#
## Available Styles
#
## style-1   style-2   style-3   style-4   style-5
## style-6   style-7   style-8   style-9   style-10

# Resolve the bundled theme relative to this script so the Waybar folder is portable.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
theme="$SCRIPT_DIR/../themes/Red-Theme.rasi"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# CMDs
uptime="`uptime -p | sed -e 's/up //g'`"
host=`hostname`

# Options
shutdown=' Desligar'
reboot=' Reiniciar'
lock=' Bloquear'
suspend=' Suspender'
logout=' Sair'
yes=' Sim'
no=' Não'

# Rofi CMD
rofi_cmd() {
	rofi -dmenu \
		-p "Opções" \
		-mesg "Escolha uma opção" \
		-theme "$theme"
}

# Confirmation CMD
confirm_cmd() {
	rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
		-theme-str 'mainbox {children: [ "message", "listview" ];}' \
		-theme-str 'listview {columns: 2; lines: 1;}' \
		-theme-str 'element-text {horizontal-align: 0.5;}' \
		-theme-str 'textbox {horizontal-align: 0.5;}' \
		-dmenu \
		-p 'Confirmation' \
		-mesg 'Tem certeza?' \
		-theme "$theme"
}

# Ask for confirmation
confirm_exit() {
	echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
	selected="$(confirm_exit)"
	if [[ "$selected" == "$yes" ]]; then
		if [[ $1 == '--shutdown' ]]; then
			systemctl poweroff
		elif [[ $1 == '--reboot' ]]; then
			systemctl reboot
		elif [[ $1 == '--suspend' ]]; then
			mpc -q pause
			amixer set Master mute
			systemctl suspend
		elif [[ $1 == '--logout' ]]; then
			if [[ "$DESKTOP_SESSION" == 'openbox' ]]; then
				openbox --exit
			elif [[ "$DESKTOP_SESSION" == 'bspwm' ]]; then
				bspc quit
			elif [[ "$DESKTOP_SESSION" == 'i3' ]]; then
				i3-msg exit
			elif [[ "$DESKTOP_SESSION" == 'plasma' ]]; then
				qdbus org.kde.ksmserver /KSMServer logout 0 0 0
			elif [[ "$DESKTOP_SESSION" == 'hyprland' || "$XDG_CURRENT_DESKTOP" == 'Hyprland' ]]; then
				hyprctl dispatch exit
			fi
		fi
	else
		exit 0
	fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $shutdown)
		run_cmd --shutdown
        ;;
    $reboot)
		run_cmd --reboot
        ;;
	$lock)
		if command -v hyprlock >/dev/null 2>&1; then
			# Resolve Hyprlock's background from the wallpaper currently selected in Hyprpaper.
			wallpaper="$(sed -n 's/^[[:space:]]*path[[:space:]]*=[[:space:]]*//p' "$CONFIG_HOME/hypr/hyprpaper.conf" 2>/dev/null | head -n 1)"
			if [[ "$wallpaper" == '~/'* ]]; then
				wallpaper="$HOME/${wallpaper#~/}"
			fi
			if [[ -n "$wallpaper" && -f "$wallpaper" ]]; then
				mkdir -p "$CACHE_HOME/waybar"
				ln -sfn -- "$wallpaper" "$CACHE_HOME/waybar/lockscreen-wallpaper"
			fi
			hyprlock --config "$SCRIPT_DIR/../hyprlock.conf"
		else
			notify-send "Bloqueio de tela" "Instale o pacote hyprlock para usar esta opção."
		fi
        ;;
    $suspend)
		run_cmd --suspend
        ;;
    $logout)
		run_cmd --logout
        ;;
esac
