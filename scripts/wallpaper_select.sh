#!/usr/bin/env bash

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
HYPRPAPER_CONFIG="$CONFIG_HOME/hypr/hyprpaper.conf"

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpapers" "Crie a pasta ~/Pictures/Wallpapers (ou ~/Imagens/Wallpapers) e adicione imagens."
    exit 1
fi

mkdir -p "$CACHE_DIR"

# Gera miniaturas para wallpapers que ainda não têm cache
for img in "$WALLPAPER_DIR"/*.{png,jpg,jpeg}; do
    [ -f "$img" ] || continue
    filename=$(basename "$img")
    thumb="$CACHE_DIR/$filename"
    if [ ! -f "$thumb" ]; then
        ffmpeg -i "$img" -vf "scale=250:-1" "$thumb" -y >/dev/null 2>&1
    fi
done

# Monta a lista formatada para o Rofi com ícones
SELECTED=$(for img in "$WALLPAPER_DIR"/*.{png,jpg,jpeg}; do
    [ -f "$img" ] || continue
    filename=$(basename "$img")
    echo -en "$filename\0icon\x1f$CACHE_DIR/$filename\n"
done | rofi -dmenu -p "Wallpapers" -show-icons -theme-str 'listview { columns: 3; lines: 2; } element { orientation: vertical; } element-icon { size: 120px; }')

# Aplica a imagem escolhida usando a nova sintaxe do hyprpaper
if [ -n "$SELECTED" ]; then
    FULL_PATH="$WALLPAPER_DIR/$SELECTED"
    
    # Atualiza o arquivo hyprpaper.conf
    mkdir -p "$(dirname -- "$HYPRPAPER_CONFIG")"
    cat <<EOF > "$HYPRPAPER_CONFIG"
wallpaper {
    monitor =
    path = $FULL_PATH
    fit_mode = cover
}
splash = false
ipc = on
EOF

    # Recarrega o hyprpaper
    killall hyprpaper
    hyprpaper &
fi
