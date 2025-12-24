#!/usr/bin/env bash

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

PASS_FILE="$BASE_DIR/modules/passwords.txt"

read -rp "[*] Hladane heslo v passwords.txt ? Heslo: " search
echo

# kontrola existencie suboru
if [[ ! -f "$PASS_FILE" ]]; then
  echo "[-] Subor passwords.txt neexistuje: $PASS_FILE"
  exit 1
fi

# presne hladanie celeho riadku
if grep -Fxqi -- "$search" "$PASS_FILE"; then
  found=$(grep -Fxni -- "$search" "$PASS_FILE")
  echo "[+] Uspech, heslo najdene (riadok:heslo):"
  echo "$found"
else
  echo "[-] Heslo sa v zozname nenachadza"
fi
