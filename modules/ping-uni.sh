#!/usr/bin/env bash

# absolutna cesta k adresaru modulu
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# import spolocnej funkcie na vyber URL
source "$BASE_DIR/lib/targets.sh" || {
    echo "[-] Nepodarilo sa nacitat lib/targets.sh"
    exit 1
}

# funkcia na testovanie odozvy
test_response() {
    local url="$1"
    local requests="$2"

    echo
    echo "[*] Testujem odozvu pre: $url"
    echo "--------------------------------"

    for ((i=1; i<=requests; i++)); do
        echo "[?] $i. poziadavka..."

        curl -o /dev/null -s \
             -w "    Kod: %{http_code}, Cas: %{time_total}s\n" \
             "$url"

        sleep 2
    done
}

# volanie funkcie na vyber cielenej URL
select_target || exit 1

# zadanie poctu poziadaviek
read -rp "[*] Zadajte pocet poziadaviek: " rq

# validacia vstupu – musi byt cislo
[[ "$rq" =~ ^[0-9]+$ ]] || { echo "[-] Pocet poziadaviek musi byt cislo"; exit 1; }

# spustenie testu odozvy
test_response "$TARGET_URL" "$rq"
