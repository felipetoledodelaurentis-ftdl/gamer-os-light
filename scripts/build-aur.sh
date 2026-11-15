#!/usr/bin/env bash
# Compila os pacotes do AUR e coloca num repositorio local.
# Roda como usuario comum (makepkg nao aceita root).
# Uso: build-aur.sh <lista-aur.txt> <pasta-do-repositorio>
set -euo pipefail

LIST="$1"
REPO="$2"
BUILD=/tmp/aurbuild
mkdir -p "$BUILD" "$REPO"
: > "$REPO/aur-ok.txt"

echo "==> Instalando yay (ajudante do AUR)"
if ! command -v yay >/dev/null; then
    rm -rf /tmp/yay-bin
    git clone --depth 1 https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    (cd /tmp/yay-bin && makepkg -si --noconfirm)
fi

YAY_FLAGS=(--noconfirm --needed --builddir "$BUILD"
           --answerdiff None --answerclean None --answeredit None
           --removemake --mflags "--skippgpcheck")

while read -r name kind _ <&3; do
    [[ -z "${name:-}" || "$name" == \#* ]] && continue
    echo "==> AUR: $name ($kind)"
    if yay -S "${YAY_FLAGS[@]}" "$name" </dev/null; then
        echo "$name" >> "$REPO/aur-ok.txt"
    elif [[ "$kind" == "obrigatorio" ]]; then
        echo "!! Falhou pacote obrigatorio: $name" >&2
        exit 1
    else
        echo "!! Pacote opcional $name falhou, seguindo sem ele" >&2
    fi
done 3< "$LIST"

echo "==> Copiando pacotes para $REPO"
find "$BUILD" -name '*.pkg.tar.zst' ! -name '*-debug-*' -exec cp -f {} "$REPO/" \;
ls -1 "$REPO"
