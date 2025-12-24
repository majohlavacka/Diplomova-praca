#!/usr/bin/env bash
set -e  # ukonci skript ak sa akykoľvek prikaz neuskutocni neuspesne

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"  

MISS_SYS="$BASE_DIR/.missing_system"  # docasny subor - chybujuce systemove prikazy
MISS_PY="$BASE_DIR/.missing_python"   # docasny subor - chybujuce python moduly

# mapovanie prikaz - nazov balika pre apt
declare -A PKG_MAP=(
  [grep]=grep
  [sed]=sed
  [awk]=gawk
  [curl]=curl
  [wget]=wget
  [dig]=dnsutils
  [python3]=python3
  [pip3]=python3-pip
)

# ak nie je co instalovat
[[ ! -f "$MISS_SYS" && ! -f "$MISS_PY" ]] && {
  echo "[+] Nie je co instalovat"
  exit 0
}

SYS=()  # pole pre systemove prikazy
PY=()   # pole pre python baliky

[[ -f "$MISS_SYS" ]] && mapfile -t SYS < "$MISS_SYS"  # nacita chybujuce prikazy
[[ -f "$MISS_PY" ]] && mapfile -t PY < "$MISS_PY"     # nacita chybujuce python baliky

echo "[*] Chybajuce zavislosti:"

for s in "${SYS[@]}"; do
  echo "  - system: $s -> ${PKG_MAP[$s]}"  # vypise prikaz a jeho balik
done

for p in "${PY[@]}"; do
  echo "  - python: $p" # vypise python balik
done

echo
read -rp "[?] Chces tieto zavislosti nainstalovat? [y/N]: " answ
[[ "$answ" =~ ^[Yy]$ ]] || { echo "[-] Instalacia zrusena"; exit 1; }

# kontrola root
[[ $EUID -ne 0 ]] && {
  echo "[-] Spusti ako root: sudo bash requirements/install.sh"
  exit 1
}

# SYSTEMOVE BALIKY
PKGS=()
for s in "${SYS[@]}"; do
  [[ -n "${PKG_MAP[$s]}" ]] && PKGS+=("${PKG_MAP[$s]}")  # pripravi zoznam balikov pre apt
done

if [[ ${#PKGS[@]} -gt 0 ]]; then
  echo
  echo "[*] Instalujem systemove baliky: ${PKGS[*]}"
  apt update
  apt install -y "${PKGS[@]}"
fi

# PYTHON KNIZNICE 
if [[ ${#PY[@]} -gt 0 ]]; then
  echo
  echo "[*] Instalujem Python kniznice: ${PY[*]}"
  pip3 install --upgrade pip
  pip3 install "${PY[@]}"
fi

# vymaze docasne subory po instalacii
rm -f "$MISS_SYS" "$MISS_PY"

echo
echo "[+] Instalacia dokoncena"
