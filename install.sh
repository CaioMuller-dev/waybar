#!/usr/bin/env bash

## Author: Caio Muller (kalice)
## GitHub: @CaioMuller-dev

set -euo pipefail

SOURCE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
DEST_DIR="$CONFIG_HOME/waybar"

for item in config.jsonc style.css hyprlock.conf scripts themes; do
    if [[ ! -e "$SOURCE_DIR/$item" ]]; then
        printf 'Erro: não encontrei %s em %s\n' "$item" "$SOURCE_DIR" >&2
        exit 1
    fi
done

mkdir -p "$DEST_DIR"
DEST_DIR="$(cd -- "$DEST_DIR" && pwd -P)"

# O repositório também pode ser instalado diretamente em ~/.config/waybar.
if [[ "$SOURCE_DIR" == "$DEST_DIR" ]]; then
    chmod +x "$DEST_DIR"/scripts/*.sh
    printf 'A Waybar já está instalada em %s. Permissões dos scripts conferidas.\n' "$DEST_DIR"
    exit 0
fi

backup_dir=""
for item in config.jsonc style.css hyprlock.conf scripts themes; do
    if [[ -e "$DEST_DIR/$item" ]]; then
        if [[ -z "$backup_dir" ]]; then
            backup_dir="${DEST_DIR}.backup-$(date +%Y%m%d-%H%M%S)"
            mkdir -p "$backup_dir"
        fi
        mv -- "$DEST_DIR/$item" "$backup_dir/"
    fi
done

cp -- "$SOURCE_DIR/config.jsonc" "$SOURCE_DIR/style.css" "$SOURCE_DIR/hyprlock.conf" "$DEST_DIR/"
cp -a -- "$SOURCE_DIR/scripts" "$SOURCE_DIR/themes" "$DEST_DIR/"
chmod +x "$DEST_DIR"/scripts/*.sh

printf 'Waybar instalada em %s\n' "$DEST_DIR"
if [[ -n "$backup_dir" ]]; then
    printf 'Arquivos anteriores guardados em %s\n' "$backup_dir"
fi
