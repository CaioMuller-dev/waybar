# Waybar Kalice

Configuração personalizada da Waybar para sessões Wayland com Hyprland. O projeto reúne a configuração JSONC, o tema CSS e scripts para rede, Bluetooth, wallpapers, desempenho e menu de energia.

## Índice

- [Descrição](#descrição)
- [Módulos e funcionalidades](#módulos-e-funcionalidades)
- [Dependências](#dependências)
- [Instalação no Arch Linux](#instalação-no-arch-linux)
- [Instalação dos arquivos](#instalação-dos-arquivos)
- [Inicialização e uso](#inicialização-e-uso)
- [Permissões e observações](#permissões-e-observações)
- [Solução de problemas](#solução-de-problemas)

## Descrição

Esta configuração organiza a barra em três áreas: espaços de trabalho, uso do sistema, relógio, música, rede, Bluetooth, áudio, brilho, bateria, modo de desempenho e menu de energia. A aparência é definida em `style.css`; os comandos dos módulos personalizados estão em `scripts/`.

Waybar é uma barra para Wayland. Esta configuração usa o módulo `hyprland/workspaces` e, portanto, foi preparada para ser executada dentro do Hyprland.

## Módulos e funcionalidades

| Área | Módulos | O que mostram ou fazem |
| :--- | :--- | :--- |
| Esquerda | Workspaces do Hyprland, uptime, memória e CPU | Espaços de trabalho e informações básicas do sistema. Clique na CPU abre o `htop` no Kitty. |
| Centro | Wallpaper, relógio e Spotify | Abre o seletor de wallpapers, alterna o formato do relógio e inicia o Spotify. |
| Direita | Música, Bluetooth, rede, áudio, brilho, bateria, desempenho e energia | Exibe estados do sistema e abre controles e menus ao clicar. |

## Dependências

### Essenciais para esta configuração

- **Waybar**: barra e módulos nativos.
- **Hyprland**: compositor Wayland usado pelo módulo de workspaces.
- **FiraCode Nerd Font**: fonte definida no CSS e necessária para os ícones.
- **Bash e utilitários GNU**: execução dos scripts e comandos como `sed`, `awk`, `uptime`, `cat` e `mkdir`.
- **playerctl**: metadados e controles de reprodução.
- **NetworkManager**: `nmcli` para detectar a rede; `nmtui` para abrir a interface de rede no terminal.
- **BlueZ**: `bluetoothctl` para controlar o Bluetooth.
- **Servidor de áudio compatível com PulseAudio**: necessário para o módulo `pulseaudio`. Em instalações PipeWire, use `pipewire-pulse` e `wireplumber`.
- **libnotify**: comando `notify-send`, usado pelos avisos dos scripts.

O próprio pacote Waybar instala suas bibliotecas necessárias pelo pacman. Não é preciso instalar manualmente as bibliotecas de compilação.

### Usadas por ações específicas

| Pacote/comando | Uso |
| :--- | :--- |
| `rofi` | Seletor de wallpapers e menu de energia. O seletor usa `themes/Red-Theme.rasi`, incluído neste repositório. |
| `ffmpeg` | Cria miniaturas de wallpapers. |
| `hyprpaper` | Aplica o wallpaper selecionado. |
| `hyprlock` | Bloqueia a sessão pelo menu de energia. |
| `brightnessctl` | Ajusta o brilho ao rolar sobre o módulo. |
| `pavucontrol` | Abre o controle gráfico de áudio. |
| `blueman` | Abre o gerenciador Bluetooth com clique direito. |
| `kitty` e `htop` | Terminal e monitor de processos abertos pelos cliques da barra. |
| `systemd` | Comando `systemctl` para desligar, reiniciar ou suspender. |
| `sudo` e suporte a `cpufreq` | Script de desempenho altera o governor da CPU. Pode não funcionar em todo hardware/kernel. |
| `spotify-launcher` | Inicia o Spotify pelo ícone central. É opcional e pode exigir configuração/conta. |
| `mpc` e `alsa-utils` | O menu tenta pausar o MPD e silenciar o mixer ao suspender. São opcionais. |

### Instalação dos pacotes no Arch Linux

Atualize o sistema e instale a base e os utilitários usados pela configuração:

```bash
sudo pacman -Syu
sudo pacman -S waybar hyprland hyprlock ttf-firacode-nerd playerctl networkmanager bluez bluez-utils rofi ffmpeg hyprpaper libnotify brightnessctl pavucontrol blueman kitty htop pipewire pipewire-pulse wireplumber
```

Se já usa outro compositor, não precisa instalar o Hyprland. Se já tem outro servidor de áudio PulseAudio, não instale nem troque o servidor sem antes conferir a configuração atual do sistema.

Instale os complementos opcionais somente se quiser usar essas funções:

```bash
sudo pacman -S mpc alsa-utils
```

O Spotify pode ser instalado pelo pacote `spotify-launcher` quando disponível nos repositórios configurados. Caso não esteja disponível, consulte o método de instalação atual do Arch/AUR antes de instalar um pacote de terceiros.

Ative os serviços de rede e Bluetooth, se ainda não estiverem ativos:

```bash
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
```

Em um computador que já tenha esses serviços configurados, não é necessário habilitá-los novamente.

## Instalação dos arquivos

Faça backup de uma configuração existente e copie os arquivos do repositório para o diretório padrão do usuário:

```bash
mkdir -p ~/.config/waybar
cp -r config.jsonc style.css hyprlock.conf scripts themes ~/.config/waybar/
```

Execute esses comandos a partir da pasta do repositório. Se o clone estiver em outro local, informe os caminhos completos. Os scripts precisam manter a permissão de execução; para garantir isso:

```bash
chmod +x ~/.config/waybar/scripts/*.sh
```

Para obter o repositório via HTTPS:

```bash
git clone https://github.com/CaioMuller-dev/waybar.git
cd waybar
```

Se você já está dentro do clone, pule os comandos de clone. A configuração referencia os scripts por `XDG_CONFIG_HOME` ou `~/.config`, então mantenha a estrutura `~/.config/waybar/scripts/` e `~/.config/waybar/themes/`.

### Wallpapers

O seletor procura imagens PNG, JPG ou JPEG em `~/Pictures/Wallpapers` ou `~/Imagens/Wallpapers` (também considera o diretório de imagens definido pelo usuário). Crie a pasta e adicione imagens:

```bash
mkdir -p ~/Pictures/Wallpapers
```

O script gera miniaturas em `~/.cache/waybar/wallpaper_thumbs`, grava a seleção em `~/.config/hypr/hyprpaper.conf` e aplica a imagem pelo IPC do Hyprpaper (`hyprctl`). O menu de bloqueio sincroniza essa imagem com o fundo do Hyprlock, usando uma versão desfocada para manter a leitura do relógio e do campo de senha.

## Inicialização e uso

Inicie uma sessão Wayland do Hyprland e execute:

```bash
waybar
```

Para iniciar automaticamente, adicione `exec-once = waybar` à configuração do Hyprland (`~/.config/hypr/hyprland.conf`) ou use a forma equivalente na configuração Lua do Hyprland. Evite iniciar duas instâncias ao mesmo tempo.

Os principais cliques configurados são:

- **CPU:** abre `htop` no Kitty.
- **Wallpaper:** abre o seletor Rofi e aplica a imagem com Hyprpaper.
- **Spotify:** inicia o aplicativo.
- **Música:** alterna play/pause com `playerctl`.
- **Bluetooth:** alterna o rádio; clique direito abre Blueman.
- **Rede:** abre `nmtui` no Kitty.
- **Áudio:** abre `pavucontrol`.
- **Desempenho:** alterna entre os governors `performance` e `powersave`.
- **Energia:** abre o menu para bloquear, suspender, sair, reiniciar ou desligar.

## Permissões e observações

- A instalação de pacotes e a ativação de serviços pedem a senha administrativa via `sudo`.
- O módulo de desempenho chama `sudo` para gravar em `/sys/devices/system/cpu/.../scaling_governor`. A execução por clique pode não ter um terminal para mostrar o pedido de senha. Se isso ocorrer, execute o script manualmente em um terminal para diagnosticar; não configure `sudo` sem senha de forma ampla. O recurso também depende de suporte do kernel e da CPU.
- Desligar, reiniciar e suspender normalmente são autorizados pelo systemd na sessão local, mas políticas da distribuição podem variar.
- O controle de brilho precisa que o dispositivo de backlight esteja acessível ao usuário.
- Bluetooth e rede dependem dos respectivos serviços e adaptadores.
- O módulo de bateria só mostrará dados em equipamentos com bateria reconhecida pelo sistema.
- O ícone de Spotify só inicia o aplicativo; o módulo de música lê metadados de players compatíveis via MPRIS e `playerctl`.
- O menu carrega a configuração `hyprlock.conf` incluída neste repositório. Ela pode ser personalizada; não é necessário criar `~/.config/hypr/hyprlock.conf` para usar o menu.
- Ícones ausentes geralmente indicam que a fonte Nerd Font não foi instalada ou selecionada corretamente.

## Solução de problemas

Execute Waybar pelo terminal para ver mensagens de erro:

```bash
waybar
```

Confira se os principais comandos estão disponíveis:

```bash
command -v waybar playerctl nmcli bluetoothctl rofi ffmpeg hyprpaper
```

Se um módulo personalizado não aparecer, confira se o script existe e é executável:

```bash
ls -l ~/.config/waybar/scripts
```

Após alterar os arquivos, encerre a instância atual e inicie novamente:

```bash
pkill waybar
waybar
```

## Referências

- [Waybar no ArchWiki](https://wiki.archlinux.org/title/Waybar)
- [Pacote Waybar no Arch Linux](https://archlinux.org/packages/extra/x86_64/waybar/)
- [Manual de configuração da Waybar](https://man.archlinux.org/man/waybar.5)
