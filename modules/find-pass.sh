#!/usr/bin/env bash

read -p "[*] Hladane heslo v passwords.txt ? Heslo: " f
echo

if grep -i -q "$f" modules/passwords.txt &> /dev/null; then
  found=$(grep -i -n "$f" modules/passwords.txt)
  echo "[+] Uspech, heslo najdene (riadok:heslo): $found"
else
  echo "[-] Heslo sa v zozname nenachadza"
fi
