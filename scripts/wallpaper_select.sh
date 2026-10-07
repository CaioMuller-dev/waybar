#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Use the user's configured pictures directory when available, then common defaults.
PICTURES_DIR=""
if [ -r "$CONFIG_HOME/user-dirs.dirs" ]; then
    PICTURES_DIR=$(sed -n 's/^XDG_PICTURES_DIR="\(.*\)"$/\1/p' "$CONFIG_HOME/user-dirs.dirs" | head -n 1)
    PICTURES_DIR=${PICTURES_DIR//\$HOME/$HOME}
fi
if [ -n "$PICTURES_DIR" ] && [ -d "$PICTURES_DIR/Wallpapers" ]; then
    WALLPAPER_DIR="$PICTURES_DIR/Wallpapers"
elif [ -d "$HOME/Pictures/Wallpapers" ]; then
    WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
elif [ -d "$HOME/Imagens/Wallpapers" ]; then
    WALLPAPER_DIR="$HOME/Imagens/Wallpapers"
fi
WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
CACHE_DIR="$CACHE_HOME/waybar/wallpaper_thumbs"
LOCK_WALLPAPER="$CACHE_HOME/waybar/lockscreen-wallpaper"
HYPRPAPER_CONFIG="$CONFIG_HOME/hypr/hyprpaper.conf"
ROFI_THEME="$SCRIPT_DIR/../themes/Red-Theme.rasi"

# Accept common image extensions regardless of letter case.
shopt -s nullglob nocaseglob
IMAGES=("$WALLPAPER_DIR"/*.{png,jpg,jpeg})

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpapers" "Crie a pasta ~/Pictures/Wallpapers (ou ~/Imagens/Wallpapers) e adicione imagens."
    exit 1
fi

if [ "${#IMAGES[@]}" -eq 0 ]; then
    notify-send "Wallpapers" "Nenhuma imagem PNG, JPG ou JPEG foi encontrada em $WALLPAPER_DIR."
    exit 1
fi

if ! command -v rofi >/dev/null 2>&1; then
    notify-send "Wallpapers" "O Rofi não está instalado."
    exit 1
fi

mkdir -p "$CACHE_DIR"

# Gera miniaturas para wallpapers que ainda não têm cache
for img in "${IMAGES[@]}"; do
    filename=$(basename "$img")
    thumb="$CACHE_DIR/$filename"
    if [ ! -f "$thumb" ]; then
        ffmpeg -i "$img" -vf "scale=250:-1" "$thumb" -y >/dev/null 2>&1
    fi
done

# Monta a lista formatada para o Rofi com ícones
SELECTED=$(for img in "${IMAGES[@]}"; do
    filename=$(basename "$img")
    printf '%s\0icon\x1f%s\n' "$filename" "$CACHE_DIR/$filename"
done | rofi -no-config -dmenu -p "Wallpapers" -show-icons \
    -theme "$ROFI_THEME" \
    -theme-str 'listview { columns: 3; lines: 2; } element { orientation: vertical; } element-icon { size: 120px; }')

# Aplica a imagem escolhida e mantém a seleção para a próxima sessão.
if [ -n "$SELECTED" ]; then
    FULL_PATH="$WALLPAPER_DIR/$SELECTED"

    if [ ! -f "$FULL_PATH" ]; then
        notify-send "Wallpapers" "A imagem selecionada não foi encontrada: $FULL_PATH"
        exit 1
    fi

    # Keep Hyprlock pointed at the same image selected for Hyprpaper.
    ln -sfn -- "$FULL_PATH" "$LOCK_WALLPAPER"
    
    # Atualiza o arquivo hyprpaper.conf
    mkdir -p "$(dirname -- "$HYPRPAPER_CONFIG")"
    cat <<EOF > "$HYPRPAPER_CONFIG"
wallpaper {
    monitor =
    path = $FULL_PATH
    fit_mode = cover
}
splash = false
ipc = true
EOF

    # Update the running Hyprpaper instance through its IPC interface.
    if ! hyprctl hyprpaper wallpaper ", $FULL_PATH, cover"; then
        notify-send "Wallpapers" "Não foi possível aplicar a imagem. Confira se o Hyprpaper está rodando e com IPC ativo."
        exit 1
    fi
fi
