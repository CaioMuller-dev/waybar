# Waybar Kalice

Configuração de Waybar para Hyprland no Arch Linux. O repositório inclui a configuração JSONC, o CSS, o tema do Rofi, scripts auxiliares e a configuração do Hyprlock usada pelo menu de energia.

## O que a configuração usa

- **Esquerda:** workspaces do Hyprland, uptime, memória e CPU. Clicar em memória ou CPU abre `htop` no Kitty.
- **Centro:** seletor de wallpaper, relógio e atalho para Spotify.
- **Direita:** controles de música, Bluetooth, rede, áudio, brilho, bateria, governor da CPU e energia.
- **Scripts:** `wallpaper_select.sh`, `bluetooth_toggle.sh`, `network_icon.sh`, `performance_mode.sh`, `set_governor.sh` e `power_menu.sh`.

Os wallpapers são arquivos pessoais e não fazem parte deste repositório. O seletor procura imagens em `~/Pictures/Wallpapers`, `~/Imagens/Wallpapers` ou na pasta `Wallpapers` dentro do diretório de imagens configurado no sistema. A configuração ativa do Hyprpaper é criada em `~/.config/hypr/hyprpaper.conf`; miniaturas e a imagem de bloqueio ficam no cache do usuário.

## Dependências

### Necessárias para a sessão e os módulos

- Waybar e Hyprland (o módulo de workspaces é `hyprland/workspaces`).
- `ttf-firacode-nerd` para os ícones da Waybar e a fonte da tela de bloqueio.
- `playerctl` para o módulo de música.
- NetworkManager e `bluez`/`bluez-utils` para rede e Bluetooth (`nmcli`, `nmtui` e `bluetoothctl`).
- `pipewire`, `pipewire-pulse` e `wireplumber` para áudio em uma instalação PipeWire.
- `brightnessctl` para controle de brilho; `libnotify` para avisos dos scripts.
- `rofi` para os menus de wallpaper e energia.
- `ffmpeg` para gerar miniaturas, `hyprpaper` para aplicar wallpapers e `hyprctl` (fornecido pelo Hyprland) para falar com os serviços Hyprland/Hyprpaper.
- `kitty` e `htop` para as ações de clique em memória/CPU e rede.
- `pavucontrol` para abrir o mixer gráfico e `blueman` para abrir o gerenciador Bluetooth.

O tema do Rofi usa **Hack Nerd Font Propo**. Instale essa fonte para que o menu use a tipografia esperada; os ícones e a Waybar usam FiraCode Nerd Font. No Arch Linux, o pacote `ttf-hack-nerd` fornece Hack Nerd Font.

### Opcionais

- `spotify-launcher` para iniciar Spotify pelo ícone central.
- `mpc` e `alsa-utils` para pausar MPD e silenciar o mixer ao suspender.
- Suporte a `cpufreq` no kernel/hardware e autorização via `sudo` para alternar o governor. Sem esse suporte, o módulo de desempenho não funciona.

## Instalação no Arch Linux

Instale os pacotes usados pelos módulos. Se já usa outro compositor ou servidor de áudio, não instale/substitua Hyprland ou PipeWire sem considerar sua instalação atual.

```bash
sudo pacman -Syu
sudo pacman -S waybar hyprland hyprlock hyprpaper ttf-firacode-nerd ttf-hack-nerd playerctl networkmanager bluez bluez-utils pipewire pipewire-pulse wireplumber rofi ffmpeg libnotify brightnessctl pavucontrol blueman kitty htop
```

Ative NetworkManager e Bluetooth se ainda não estiverem ativos:

```bash
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
```

Para habilitar funções opcionais:

```bash
sudo pacman -S mpc alsa-utils
```

Instale `spotify-launcher` pelo método disponível para sua instalação do Arch, caso queira usar o atalho. O pacote pode não estar nos repositórios habilitados.

## Baixar e instalar os arquivos

Clone o projeto em uma pasta de trabalho:

```bash
git clone https://github.com/CaioMuller-dev/waybar.git ~/waybar
```

Se `~/waybar` já existir, atualize-o com `git -C ~/waybar pull` em vez de cloná-lo novamente. Faça backup da configuração existente antes de copiar. Estes comandos guardam o backup com data e instalam os arquivos nos caminhos que a configuração espera:

```bash
if [ -d ~/.config/waybar ]; then
  mv ~/.config/waybar ~/.config/waybar.backup-$(date +%Y%m%d-%H%M%S)
fi
mkdir -p ~/.config/waybar
cp ~/waybar/config.jsonc ~/waybar/style.css ~/waybar/hyprlock.conf ~/.config/waybar/
cp -a ~/waybar/scripts ~/waybar/themes ~/.config/waybar/
```

Os bits executáveis dos scripts estão registrados no Git e são preservados por `cp -a`. Se você copiou os scripts por outro método, restaure-os com:

```bash
chmod +x ~/.config/waybar/scripts/*.sh
```

O caminho `~/waybar` é apenas a pasta de clone sugerida; se escolheu outra, ajuste os comandos de cópia. A configuração dos módulos usa `XDG_CONFIG_HOME` quando chama os scripts. O arquivo de Hyprlock usa o caminho padrão `~/.cache/waybar/lockscreen-wallpaper`.

## Preparar wallpapers e iniciar

Crie uma das pastas de wallpapers reconhecidas e adicione imagens PNG, JPG ou JPEG:

```bash
mkdir -p ~/Pictures/Wallpapers
```

O Hyprland deve iniciar tanto Waybar quanto Hyprpaper. Esta configuração do usuário usa `~/.config/hypr/hyprland.lua`; adicione comandos equivalentes na seção de inicialização da sua configuração, se ainda não existirem:

```lua
hl.exec_cmd("waybar")
hl.exec_cmd("hyprpaper")
```

Para iniciar manualmente a Waybar durante a sessão Hyprland:

```bash
waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css
```

O menu de energia inicia o Hyprlock com `~/.config/waybar/hyprlock.conf`. O seletor de wallpaper atualiza `~/.config/hypr/hyprpaper.conf` e envia o wallpaper ao Hyprpaper em execução.

## Ações e limitações

- Clique em wallpaper abre o seletor Rofi; clique em relógio alterna o formato; clique no Spotify tenta executar `spotify`.
- Clique em música alterna play/pause via MPRIS e `playerctl`.
- Bluetooth alterna o rádio; clique direito abre Blueman. Rede abre `nmtui` no Kitty.
- Áudio abre `pavucontrol`; rolar no brilho altera o nível em passos de 5%.
- Clique no módulo de desempenho alterna entre `performance` e `powersave` usando `sudo`. Dependendo do sistema, o pedido de senha não aparece ao clicar na barra; teste o script num terminal e confira o suporte de governor antes de configurar autorização adicional.
- O menu de energia oferece bloqueio, suspensão, logout, reinício e desligamento. MPD e `amixer` só são chamados na suspensão e são opcionais.
- O módulo de bateria só mostra informações quando o sistema detecta uma bateria.

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

Após alterações, reinicie a Waybar dentro da sessão Hyprland. Evite manter duas instâncias em execução.

## Referências

- [Waybar no ArchWiki](https://wiki.archlinux.org/title/Waybar)
- [Pacote Waybar no Arch Linux](https://archlinux.org/packages/extra/x86_64/waybar/)
- [Manual de configuração da Waybar](https://man.archlinux.org/man/waybar.5)
