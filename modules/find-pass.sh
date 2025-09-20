#!/bin/bash

echo "[*]Hladane heslo v passwords.txt ? : "
read -p "Heslo: " f
echo

grep -i -q "$f" passwords.txt &> /dev/null

if [ $? -eq 0 ]; then
  echo "[+] Uspech, heslo najdene: $f"
else
  echo "[-] Heslo sa v zozname nenachadza"
fi
