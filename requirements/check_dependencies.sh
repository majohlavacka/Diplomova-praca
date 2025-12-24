#!/usr/bin/env bash
set -e  # ukonci skript ak sa akykoľvek prikaz neuskutocni uspesne

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"  # absolutna cesta k priecinku skriptu

SYS_REQ="$BASE_DIR/bash.txt"       # subor so zoznamom systemovych prikazov
PY_REQ="$BASE_DIR/python.txt"      # subor s pip nazvami a import modulmi pythonu

MISS_SYS="$BASE_DIR/.missing_system"  # docasny subor pre chybujuce systemove prikazy
MISS_PY="$BASE_DIR/.missing_python"   # docasny subor pre chybujuce python moduly

> "$MISS_SYS"  # vymaze alebo vytvori prazdny subor
> "$MISS_PY"

check_cmd() {   # funkcia na kontrolu existencie prikazu
  command -v "$1" >/dev/null 2>&1
}

echo "[*] Kontrola systemovych zavislosti..."

while read -r cmd; do
  [[ -z "$cmd" ]] && continue           # preskoci prazdne riadky
  if check_cmd "$cmd"; then
    echo "[+] $cmd OK"
  else
    echo "[-] $cmd CHYBA"
    echo "$cmd" >> "$MISS_SYS"          # zapise chybujuce prikazy do suboru
  fi
done < "$SYS_REQ"

echo
echo "[*] Kontrola Python kniznic..."

while read -r line; do
  [[ -z "$line" ]] && continue

  pip_name="${line%%:*}"                # pip nazov balika
  import_name="${line##*:}"             # nazov modulu pre import

  if python3 - <<EOF 2>/dev/null
import $import_name
EOF
  then
    echo "[+] python:$pip_name OK"
  else
    echo "[-] python:$pip_name CHYBA"
    echo "$pip_name" >> "$MISS_PY"      # zapise chybujuce python baliky do suboru
  fi
done < "$PY_REQ"

echo
CHYBA=false

[[ -s "$MISS_SYS" ]] && { echo "[-] Chybuju systemove nastroje:"; cat "$MISS_SYS"; CHYBA=true; }
[[ -s "$MISS_PY" ]] && { echo; echo "[-] Chybuju Python kniznice:"; cat "$MISS_PY"; CHYBA=true; }

if ! $CHYBA; then
  echo
  echo "[+] Vsetky zavislosti su splnene"
  echo "[*] Spustam nastroj..."
  rm -f "$MISS_SYS" "$MISS_PY"        # vymaze docasne subory po uspechu
  exit 0
fi

echo
read -rp "[?] Chcete doinstalovat chybujuce zavislosti? [y/N]: " answ
if [[ "$answ" =~ ^[Yy]$ ]]; then
  echo "[*] Vyziadanie sudo opravneni..."
  sudo -v || { echo "[-] Sudo zrusene"; exit 1; }

  echo "[*] Spustam install.sh..."
  sudo bash "$BASE_DIR/install.sh" # zavola instalacny skript ako sudo
else
  echo "[-] Instalacia zrusena"
fi

exit 0
