#!/usr/bin/env bash

BASE_DIR="mirrors"
mkdir -p "$BASE_DIR"

echo "[*] Zvol URL na testovanie:"
echo "[a] UKF Webmail"
echo "[b] UKF AiS"
echo
read -p "Moznost: " ch

if [[ "$ch" == "a" ]]; then
    url="https://studentmail.ukf.sk/webmail/"
    name="webmail"
elif [[ "$ch" == "b" ]]; then
    url="https://ais2.ukf.sk/ais/start.do"
    name="ais"
else
    echo "[-] Neplatna volba."
    exit 1
fi

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUT_DIR="${BASE_DIR}/${name}_${TIMESTAMP}"

echo
echo "[*] Mirrorujem: $url"
echo "[*] Ukladam do: $OUT_DIR"
echo

mkdir -p "$OUT_DIR"

wget -P "$OUT_DIR" \
     --page-requisites --convert-links --adjust-extension \
     --no-parent "$url"

if [[ $? -eq 0 ]]; then
    echo
    echo "[+] Mirror hotovy: $OUT_DIR"
else
    echo
    echo "[-] Chyba pri mirrorovani"
fi
