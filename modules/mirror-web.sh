#!/usr/bin/env bash

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
MIRROR_DIR="$BASE_DIR/mirrors"

mkdir -p "$MIRROR_DIR"

# vyber URL
echo "[*] Zvol URL na testovanie:"
echo "[a] UKF Webmail"
echo "[b] UKF AiS"
echo
read -rp "Moznost: " ch

# nastavenie url a nazvu suboru podla volby
case "$ch" in
    a) url="https://studentmail.ukf.sk/webmail/"; name="webmail" ;;
    b) url="https://ais2.ukf.sk/ais/start.do"; name="ais" ;;
    *) echo "[-] Neplatna volba."; exit 1 ;;
esac

# timestamp pre unikatny nazov adresara
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUT_DIR="${MIRROR_DIR}/${name}_${TIMESTAMP}"

echo
echo "[*] Mirrorujem: $url"
echo "[*] Ukladam do: $OUT_DIR"
echo

# vytvorenie vystupneho adresara
mkdir -p "$OUT_DIR"

# spustenie mirrorovania pomocou wget
wget -P "$OUT_DIR" \
     --page-requisites --convert-links --adjust-extension \
     --no-parent "$url"

# kontrola vysledku
if [[ $? -eq 0 ]]; then
    echo
    echo "[+] Mirror hotovy: $OUT_DIR"
else
    echo
    echo "[-] Chyba pri mirrorovani"
fi
