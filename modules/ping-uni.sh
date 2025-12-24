#!/usr/bin/env bash

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

echo "[*] Zvol URL na testovanie:"
echo "[a] UKF Webmail"
echo "[b] UKF AiS"
read -rp "Moznost: " domcho

case "$domcho" in
    a) url="https://studentmail.ukf.sk/webmail/" ;;
    b) url="https://ais2.ukf.sk/ais/start.do" ;;
    *) echo "[-] Nespravna volba"; exit 1 ;;
esac

read -rp "[*] Zadajte pocet poziadaviek: " rq

# validacia vstupu
[[ "$rq" =~ ^[0-9]+$ ]] || { echo "[-] Pocet poziadaviek musi byt cislo"; exit 1; }

test_response "$url" "$rq"
