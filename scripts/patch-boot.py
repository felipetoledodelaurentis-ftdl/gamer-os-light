#!/usr/bin/env python3
"""Personaliza o menu de boot da ISO (marca + entrada "modo compativel").

Uso: patch-boot.py <pasta-do-perfil-archiso>

- Troca "Arch Linux" por "Gamer OS Light" nos menus (UEFI e BIOS).
- Cria uma entrada extra com 'nomodeset' para placas de video antigas
  ou que nao iniciam a tela grafica.
"""
import re
import sys
from pathlib import Path

NAME = "Gamer OS Light"
COMPAT = f"{NAME} (modo compativel - video basico)"


def rebrand(text: str) -> str:
    text = text.replace("Arch Linux install medium", NAME)
    text = text.replace("Arch Linux", NAME)
    return text


def patch_systemd_boot(profile: Path) -> None:
    entries = sorted((profile / "efiboot" / "loader" / "entries").glob("*.conf"))
    for f in entries:
        f.write_text(rebrand(f.read_text()))
    main = [f for f in entries
            if "speech" not in f.name and "accessibility" not in f.name
            and re.search(r"^linux\s", f.read_text(), re.M)]
    if not main:
        print("systemd-boot: nenhuma entrada encontrada (ok)")
        return
    src = main[0]
    lines = []
    for line in src.read_text().splitlines():
        if line.startswith("title"):
            line = f"title    {COMPAT}"
        elif line.startswith("options"):
            line += " nomodeset"
        lines.append(line)
    dst = src.with_name(src.name.split("-")[0] + "z-gameros-compat.conf")
    dst.write_text("\n".join(lines) + "\n")
    print(f"systemd-boot: criado {dst.name}")


def duplicate_grub_entry(path: Path) -> None:
    text = rebrand(path.read_text())
    m = re.search(r"^menuentry .*?^\}\s*$", text, re.M | re.S)
    if not m:
        path.write_text(text)
        return
    block = m.group(0)
    new = re.sub(r'^menuentry "[^"]*"', f'menuentry "{COMPAT}"', block, count=1, flags=re.M)
    new = re.sub(r"--id '?[\w-]+'?", "--id 'gameros-compat'", new, count=1)
    new = re.sub(r"^(\s*linux\s.*)$", r"\1 nomodeset", new, count=1, flags=re.M)
    text = text[: m.end()] + "\n\n" + new + text[m.end():]
    path.write_text(text)
    print(f"grub: entrada compativel adicionada em {path.name}")


def patch_grub(profile: Path) -> None:
    for name in ("grub.cfg", "loopback.cfg"):
        f = profile / "grub" / name
        if f.exists():
            duplicate_grub_entry(f)


def patch_syslinux(profile: Path) -> None:
    sysdir = profile / "syslinux"
    if not sysdir.exists():
        return
    for f in sysdir.glob("*.cfg"):
        f.write_text(rebrand(f.read_text()))
    f = sysdir / "archiso_sys-linux.cfg"
    if not f.exists():
        return
    text = f.read_text()
    m = re.search(r"^LABEL \S+\n(?:(?!LABEL ).*\n)*?(?=\n|LABEL |\Z)", text, re.M)
    if not m:
        return
    block = m.group(0)
    new = re.sub(r"^LABEL \S+", "LABEL gameroscompat", block, count=1, flags=re.M)
    new = re.sub(r"^MENU LABEL .*$", f"MENU LABEL {COMPAT}", new, count=1, flags=re.M)
    new = re.sub(r"^(APPEND .*)$", r"\1 nomodeset", new, count=1, flags=re.M)
    text = text[: m.end()] + "\n" + new + text[m.end():]
    f.write_text(text)
    print("syslinux: entrada compativel adicionada")


def main() -> None:
    profile = Path(sys.argv[1])
    patch_systemd_boot(profile)
    patch_grub(profile)
    patch_syslinux(profile)


if __name__ == "__main__":
    main()
