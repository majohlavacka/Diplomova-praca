#!/usr/bin/env bash

read -rp "[*] Hladane heslo v passwords.txt ? Heslo: " search
echo

PASS_FILE="modules/passwords.txt"

# kontrola existencie suboru
if [[ ! -f "$PASS_FILE" ]]; then
  echo "[-] Subor passwords.txt neexistuje"
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
