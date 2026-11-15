# Gamer OS Light

Sistema operacional Linux para jogos, leve e com visual parecido com o Windows 11.
Baseado no Arch Linux (a mesma base do SteamOS).

## O que vem no sistema

| Recurso | Como foi feito |
|---|---|
| Base Linux | Arch Linux, kernel `linux` atualizado |
| Steam | Steam oficial + Proton (jogos de Windows), Lutris, Wine, GameMode e Gamescope |
| Visual estilo Windows 11 | KDE Plasma 6 com barra de tarefas centralizada, tema escuro "Gamer OS Light", papel de parede próprio |
| Placa de vídeo NVIDIA | Driver oficial `nvidia-open` (série GTX 16xx, RTX 20xx em diante) |
| Placa de vídeo AMD e Intel | Mesa + Vulkan (RADV / ANV), já incluso no sistema |
| Controles Xbox | Cabo USB (nativo), Bluetooth (`xpadneo`) e adaptador sem fio (`xone`) |
| Controles PlayStation | DualShock 4 e DualSense por cabo ou Bluetooth (nativo no kernel) |
| Monitor de desempenho | App **Central Gamer**: CPU, GPU, RAM, memória de vídeo e temperaturas em tempo real; FPS dentro dos jogos via MangoHud |
| Modos de energia | Economia, Normal e Alta performance (power-profiles-daemon), direto na Central Gamer |
| Escritório e internet | LibreOffice (pt-BR), Firefox (pt-BR), VLC, leitor de PDF, visualizador de imagens, calculadora |
| Instalador | Calamares, igual ao do Windows: idioma, teclado, fuso, particionamento (automático, manual ou ao lado do Windows), formatação, nome de usuário, senha e nome do PC |

## 1. Gerar a ISO (no GitHub, de graça)

1. Crie uma conta no [GitHub](https://github.com) (se ainda não tiver).
2. Crie um repositório novo chamado `gamer-os-light` e envie todos os arquivos desta pasta.
3. Abra a aba **Actions** do repositório.
4. Clique em **Gerar ISO do Gamer OS Light** e depois em **Run workflow**.
5. Espere terminar (cerca de 1 a 2 horas na primeira vez).
6. Na página da execução, em **Artifacts**, baixe `gamer-os-light-iso`. Dentro do zip está a ISO.

> Também dá para gerar num PC com Arch Linux: `sudo ./scripts/build-iso.sh`

## 2. Gravar no pen drive

Use um pen drive de **8 GB ou mais** (tudo nele será apagado).

- **Windows:** [Rufus](https://rufus.ie). Selecione a ISO e, quando perguntar, escolha **Gravar no modo Imagem DD**.
- **Qualquer sistema:** [balenaEtcher](https://etcher.balena.io).

## 3. Instalar

1. Na BIOS/UEFI do computador, **desative o Secure Boot**.
2. Ligue o PC com o pen drive conectado e abra o menu de boot (geralmente F12, F11, F8 ou Esc).
3. Escolha o pen drive. O Gamer OS Light abre direto na área de trabalho (modo de teste).
4. O instalador abre sozinho. Ele também fica no ícone **Instalar Gamer OS Light** da área de trabalho.
5. Siga as telas: idioma, fuso horário, teclado, onde instalar, seu nome, senha e nome do computador.

Se a tela ficar preta ao iniciar pelo pen drive, reinicie e escolha a opção **modo compatível - vídeo básico** no menu.

### Instalar junto com o Windows (dual boot)

- No Windows, desligue o **BitLocker** e a **Inicialização rápida** antes.
- Na tela de partições, escolha **Instalar ao lado** e arraste a divisória para definir o espaço de cada sistema.
- Ao ligar o PC, um menu vai perguntar se você quer abrir o Gamer OS Light ou o Windows.

## Estrutura do projeto

```
.github/workflows/build-iso.yml   automação que gera a ISO no GitHub
scripts/build-iso.sh              script principal de build
scripts/build-aur.sh              compila pacotes do AUR (instalador, drivers de controle)
scripts/patch-boot.py             personaliza o menu do pen drive
archiso/packages.x86_64           lista de programas do sistema
archiso/aur-packages.txt          pacotes do AUR
archiso/airootfs/                 arquivos copiados para dentro do sistema
  etc/calamares/                  configuração e visual do instalador
  usr/local/bin/gamer-center      app Central Gamer
  usr/local/bin/gameros-postinstall  ajustes após instalar (driver de vídeo, boot)
  usr/share/plasma/look-and-feel/ visual estilo Windows 11
assets/                           logo e papel de parede em SVG (editáveis)
```

## Adicionar ou remover programas

Edite `archiso/packages.x86_64` (um pacote por linha) e gere a ISO de novo.
Programas que não existirem no repositório são ignorados com aviso, sem quebrar a build.

## Limitações conhecidas

- Placas NVIDIA mais antigas que a série GTX 16xx (GTX 900/1000) não são suportadas pelo driver `nvidia-open`. Nelas, use o modo compatível e instale depois o driver antigo pelo AUR (`nvidia-580xx-dkms`).
- Secure Boot precisa ficar desativado.
- Jogos com anti-cheat que bloqueia Linux (ex.: Valorant, alguns modos de Call of Duty) não rodam. Consulte [ProtonDB](https://www.protondb.com) e [Are We Anti-Cheat Yet](https://areweanticheatyet.com).
