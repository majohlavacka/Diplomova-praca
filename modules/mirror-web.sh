#!/usr/bin/env bash

# absolutna cesta k adresaru modulu
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# adresar pre mirrorovane weby
MIRROR_DIR="$BASE_DIR/mirrors"
mkdir -p "$MIRROR_DIR"

# import spolocnej funkcie na vyber URL
source "$BASE_DIR/lib/targets.sh" || {
    echo "[-] Nepodarilo sa nacitat lib/targets.sh"
    exit 1
}

# volanie funkcie na vyber cielenej URL
select_target || exit 1

# odvodime "name" z domeny (napr. studentmail.ukf.sk -> studentmail)
name=$(echo "$TARGET_URL" | sed -E 's|https?://([^/.]+).*|\1|')

# timestamp pre unikatny nazov adresara
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUT_DIR="${MIRROR_DIR}/${name}_${TIMESTAMP}"

echo
echo "[*] Mirrorujem: $TARGET_URL"
echo "[*] Ukladam do: $OUT_DIR"
echo

# vytvorenie vystupneho adresara
mkdir -p "$OUT_DIR"

# spustenie mirrorovania pomocou wget
wget -P "$OUT_DIR" \
     --page-requisites --convert-links --adjust-extension \
     --no-parent "$TARGET_URL"

# kontrola vysledku
if [[ $? -eq 0 ]]; then
    echo
    echo "[+] Mirror hotovy: $OUT_DIR"
else
    echo
    echo "[-] Chyba pri mirrorovani"
fi
