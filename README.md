# Waybar Kalice

Configuração de Waybar para Hyprland no Arch Linux, com scripts auxiliares, tema de Rofi e configuração do Hyprlock usados pelo menu de energia.

![Waybar Kalice](WaybarPrint.png)

## Módulos

- **Esquerda:** workspaces do Hyprland, uptime, memória e CPU. Clicar em memória ou CPU abre `htop` no Kitty.
- **Centro:** seletor de wallpaper, relógio e atalho para o Spotify.
- **Direita:** música, Bluetooth, rede, áudio, brilho, bateria, governor da CPU e menu de energia.
- **Scripts:** `wallpaper_select.sh`, `bluetooth_toggle.sh`, `network_icon.sh`, `performance_mode.sh`, `set_governor.sh` e `power_menu.sh`.

Os wallpapers são pessoais e não estão no repositório. O seletor procura imagens em `~/Pictures/Wallpapers`, `~/Imagens/Wallpapers` ou na pasta `Wallpapers` dentro do diretório de imagens do sistema. A configuração ativa do Hyprpaper é gravada em `~/.config/hypr/hyprpaper.conf`; miniaturas e a imagem de bloqueio ficam no cache do usuário.

## Dependências

### Necessárias

- Waybar e Hyprland (o módulo de workspaces é `hyprland/workspaces`)
- `ttf-firacode-nerd` para os ícones da Waybar e a fonte da tela de bloqueio
- `ttf-hack-nerd` para o tema do Rofi (Hack Nerd Font Propo)
- `playerctl` para o módulo de música
- NetworkManager e `bluez`/`bluez-utils` (`nmcli`, `nmtui`, `bluetoothctl`)
- `pipewire`, `pipewire-pulse` e `wireplumber` para áudio
- `brightnessctl` para brilho e `libnotify` para notificações dos scripts
- `rofi` para os menus de wallpaper e energia
- `ffmpeg` para gerar miniaturas e `hyprpaper` para aplicar wallpapers
- `kitty` e `htop` para as ações de clique em memória/CPU e rede
- `pavucontrol` e `blueman` para os gerenciadores gráficos

### Opcionais

- `spotify-launcher` para abrir o Spotify pelo ícone central
- `mpc` e `alsa-utils` para pausar MPD e silenciar o mixer ao suspender
- Suporte a `cpufreq` no kernel/hardware e autorização via `sudo` para o governor da CPU (sem isso, o módulo de desempenho não funciona)

## Instalação

Instale os pacotes:

```bash
sudo pacman -Syu
sudo pacman -S waybar hyprland hyprlock hyprpaper ttf-firacode-nerd ttf-hack-nerd playerctl networkmanager bluez bluez-utils pipewire pipewire-pulse wireplumber rofi ffmpeg libnotify brightnessctl pavucontrol blueman kitty htop
```

Ative os serviços, se ainda não estiverem ativos:

```bash
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
```

Opcionais:

```bash
sudo pacman -S mpc alsa-utils
```

O `spotify-launcher` não está nos repositórios oficiais; instale por AUR ou pelo método de sua preferência.

## Arquivos de configuração

Clone o repositório em uma pasta de trabalho:

```bash
git clone https://github.com/CaioMuller-dev/waybar.git ~/waybar
```

Se `~/waybar` já existir, atualize com:

```bash
git -C ~/waybar pull
```

Execute o instalador a partir do clone:

```bash
cd ~/waybar
./install.sh
```

O instalador copia a configuração, o CSS, o Hyprlock, os scripts e os temas para `~/.config/waybar`, preservando as permissões de execução dos scripts. Se já existirem arquivos gerenciados com esses nomes, eles são movidos para uma pasta de backup com data. Os demais arquivos do diretório permanecem no lugar.

Se o clone já estiver em `~/.config/waybar`, rode `~/.config/waybar/install.sh`; o instalador detecta o caso e apenas confere as permissões dos scripts. O destino respeita `XDG_CONFIG_HOME`, e os módulos usam essa variável para localizar os scripts. O Hyprlock usa o caminho fixo `~/.cache/waybar/lockscreen-wallpaper`.

## Wallpapers e inicialização

Crie a pasta de wallpapers e adicione imagens PNG, JPG ou JPEG:

```bash
mkdir -p ~/Pictures/Wallpapers
```

O Hyprland precisa iniciar a Waybar e o Hyprpaper. Se sua configuração usa `~/.config/hypr/hyprland.lua`, inclua na seção de inicialização, caso ainda não exista:

```lua
hl.exec_cmd("waybar")
hl.exec_cmd("hyprpaper")
```

Para iniciar a Waybar manualmente durante a sessão:

```bash
waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css
```

O menu de energia abre o Hyprlock com `~/.config/waybar/hyprlock.conf`. O seletor de wallpaper atualiza `~/.config/hypr/hyprpaper.conf` e aplica o wallpaper no Hyprpaper em execução.

## Ações e limitações

- Clique no wallpaper abre o seletor em Rofi; clique no relógio alterna o formato; clique no Spotify executa `spotify`.
- Clique em música alterna play/pause via MPRIS (`playerctl`).
- Bluetooth alterna o rádio; clique direito abre o Blueman. Rede abre `nmtui` no Kitty.
- Áudio abre `pavucontrol`; rolar no brilho ajusta em passos de 5%.
- O módulo de desempenho alterna entre `performance` e `powersave` com `sudo`. Dependendo da configuração do sistema, o pedido de senha pode não aparecer ao clicar; teste o script num terminal antes e confira o suporte ao governor.
- O menu de energia oferece bloqueio, suspensão, logout, reinício e desligamento. `mpc` e `amixer` só são chamados na suspensão e são opcionais.
- O módulo de bateria só exibe informação quando o sistema tem bateria.

## Diagnóstico

Inicie a Waybar pelo terminal para ver erros de configuração ou comandos ausentes:

```bash
waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css
```

Confira os comandos principais e as permissões dos scripts:

```bash
command -v waybar hyprpaper hyprctl rofi ffmpeg nmcli bluetoothctl playerctl
ls -l ~/.config/waybar/scripts
```

Após mudanças, reinicie a Waybar dentro da sessão Hyprland. Evite duas instâncias rodando ao mesmo tempo.

## Referências

- [Waybar no ArchWiki](https://wiki.archlinux.org/title/Waybar)
- [Pacote Waybar no Arch Linux](https://archlinux.org/packages/extra/x86_64/waybar/)
- [Manual de configuração da Waybar](https://man.archlinux.org/man/waybar.5)
