 #!/usr/bin/env bash
# =============================================================
#  Gamer OS Light - gera a ISO
#  Roda como root dentro de um container Arch Linux (privilegiado).
#  O GitHub Actions chama este script automaticamente.
#  Para rodar no seu PC com Arch:  sudo ./scripts/build-iso.sh
# =============================================================
set -euo pipefail
shopt -s nullglob

SRC="$(cd "$(dirname "$0")/.." && pwd)"
WORK=/work
P="$WORK/profile"
A="$P/airootfs"
REPO=/localrepo
OUT="$SRC/out"

log() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }

# -------------------------------------------------------------
log "1/7 Preparando o ambiente de build"
sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
grep -q '^ParallelDownloads' /etc/pacman.conf || sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 10/' /etc/pacman.conf
pacman-key --init
pacman-key --populate archlinux
pacman -Syu --noconfirm --needed archiso git base-devel sudo python rsync

# -------------------------------------------------------------
log "2/7 Compilando pacotes do AUR (instalador Calamares, drivers de controle)"
id builder >/dev/null 2>&1 || useradd -m builder
echo 'builder ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/builder
mkdir -p "$REPO"
chown -R builder: "$REPO"
cp "$SRC/archiso/aur-packages.txt" /tmp/aur-packages.txt
cp "$SRC/scripts/build-aur.sh" /tmp/build-aur.sh
chmod 755 /tmp/build-aur.sh
su builder -c "/tmp/build-aur.sh /tmp/aur-packages.txt $REPO"
repo-add "$REPO/gameros-local.db.tar.gz" "$REPO"/*.pkg.tar.zst

# -------------------------------------------------------------
log "3/7 Montando o perfil a partir do releng do Arch"
rm -rf "$WORK"
mkdir -p "$WORK"
cp -r /usr/share/archiso/configs/releng "$P"

# Remove o que e do modo "instalacao por terminal" do Arch
find "$A/etc/systemd/system" \( -name '*networkd*' -o -name '*resolved*' -o -name 'iwd*' \
     -o -name 'cloud-init*' -o -name 'reflector*' -o -name 'sshd*' \) -exec rm -rf {} + 2>/dev/null || true
rm -rf "$A/etc/systemd/network" "$A/etc/systemd/system/getty@tty1.service.d"
rm -f  "$A/root/.zlogin" "$A/root/.automated_script.sh" "$A/etc/motd"

# Copia os arquivos do Gamer OS Light por cima
cp -a "$SRC/archiso/airootfs/." "$A/"

# Servicos habilitados (valem para o live e para o sistema instalado)
W="$A/etc/systemd/system"
mkdir -p "$W/multi-user.target.wants" "$W/bluetooth.target.wants" \
         "$W/graphical.target.wants" "$W/timers.target.wants"
ln -sf /usr/lib/systemd/system/graphical.target           "$W/default.target"
ln -sf /usr/lib/systemd/system/sddm.service               "$W/display-manager.service"
ln -sf /usr/lib/systemd/system/NetworkManager.service     "$W/multi-user.target.wants/NetworkManager.service"
ln -sf /usr/lib/systemd/system/NetworkManager-dispatcher.service "$W/dbus-org.freedesktop.nm-dispatcher.service"
ln -sf /usr/lib/systemd/system/bluetooth.service          "$W/bluetooth.target.wants/bluetooth.service"
ln -sf /usr/lib/systemd/system/bluetooth.service          "$W/dbus-org.bluez.service"
ln -sf /usr/lib/systemd/system/power-profiles-daemon.service "$W/graphical.target.wants/power-profiles-daemon.service"
ln -sf /usr/lib/systemd/system/fstrim.timer               "$W/timers.target.wants/fstrim.timer"
ln -sf /etc/systemd/system/gamer-live-setup.service       "$W/multi-user.target.wants/gamer-live-setup.service"
ln -sf /usr/share/zoneinfo/America/Sao_Paulo              "$A/etc/localtime"

# pacman.conf: multilib ligado (necessario para a Steam)
sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' "$P/pacman.conf"
# copia para o sistema final (sem o repositorio local da build)
cp "$P/pacman.conf" "$A/etc/pacman.conf"

# pacman.conf usado so na build: + repositorio local do AUR
cat >> "$P/pacman.conf" <<EOF

[gameros-local]
SigLevel = Optional TrustAll
Server = file://$REPO
EOF

# Configuracoes padrao do Calamares para modulos que nao personalizamos
# (copiadas do codigo-fonte compilado, caso o pacote nao as instale)
CALSRC="$(find /tmp/aurbuild/calamares/src -maxdepth 1 -type d -name 'calamares-*' 2>/dev/null | head -n1)"  || true
if [ -n "$CALSRC" ]; then
    for f in "$CALSRC"/src/modules/*/*.conf; do
        b="$(basename "$f")"
        [ -e "$A/etc/calamares/modules/$b" ] || cp "$f" "$A/etc/calamares/modules/$b"
    done
fi

# -------------------------------------------------------------
log "4/7 Montando a lista de pacotes"
grep -vxF -f "$SRC/archiso/packages-remove.txt" "$P/packages.x86_64" | grep -v '^\s*#' > /tmp/base.txt || true
sed -e 's/#.*//' -e 's/[[:space:]]//g' -e '/^$/d' "$SRC/archiso/packages.x86_64" > /tmp/ours.txt
sort -u /tmp/base.txt /tmp/ours.txt "$REPO/aur-ok.txt" | sed '/^$/d' > /tmp/all.txt

pacman --config "$P/pacman.conf" -Sy
: > "$P/packages.x86_64"
while read -r pkg; do
    if pacman --config "$P/pacman.conf" -Sp --noconfirm --print-format '%n' "$pkg" >/dev/null 2>&1 \
       || pacman --config "$P/pacman.conf" -Sg "$pkg" >/dev/null 2>&1; then
        echo "$pkg" >> "$P/packages.x86_64"
    else
        echo "AVISO: pacote '$pkg' nao encontrado nos repositorios, ignorado" >&2
    fi
done < /tmp/all.txt
echo "Total de pacotes: $(wc -l < "$P/packages.x86_64")"

# -------------------------------------------------------------
log "5/7 Identidade da ISO e permissoes"
sed -i \
    -e 's/^iso_name=.*/iso_name="gameroslight"/' \
    -e 's/^iso_label="ARCH_/iso_label="GAMEROS_/' \
    -e 's/^iso_publisher=.*/iso_publisher="Gamer OS Light"/' \
    -e 's/^iso_application=.*/iso_application="Gamer OS Light - Live e Instalador"/' \
    "$P/profiledef.sh"
cat >> "$P/profiledef.sh" <<'EOF'

# --- Gamer OS Light ---
file_permissions+=(
  ["/usr/local/bin/gamer-center"]="0:0:755"
  ["/usr/local/bin/gamer-live-setup"]="0:0:755"
  ["/usr/local/bin/gameros-install"]="0:0:755"
  ["/usr/local/bin/gameros-postinstall"]="0:0:755"
)
EOF

# -------------------------------------------------------------
log "6/7 Personalizando o menu de boot"
python3 "$SRC/scripts/patch-boot.py" "$P"

# -------------------------------------------------------------
log "7/7 Gerando a ISO (demora)"
mkdir -p "$OUT"
mkarchiso -v -w "$WORK/tmp" -o "$OUT" "$P"
rm -rf "$WORK/tmp"
(cd "$OUT" && for f in *.iso; do sha256sum "$f" > "$f.sha256"; done)
log "Pronto! ISO em $OUT"
ls -lh "$OUT"
