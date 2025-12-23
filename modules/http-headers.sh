#!/usr/bin/env bash

# absolutna cesta k adresaru 
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# cesty k suborom a adresarom
HEADERS_FILE="$BASE_DIR/resources/headers.txt"
LOG_DIR="$BASE_DIR/logs"

# vytvorenie logs/ ak neexistuje
mkdir -p "$LOG_DIR"

# funkcia na kontrolu HTTP hlaviciek
check_headers() {
    local url="$1"

    # ziskanie domeny z URL (bez protokolu a cesty)
    local domain
    domain=$(echo "$url" | sed -E 's|https?://([^/]+)/?.*|\1|')

    # timestamp pre unikatny nazov log suboru
    local timestamp
    timestamp=$(date '+%Y-%m-%d_%H-%M-%S')

    # nazov log suboru podla domeny a casu spustenia
    local log_file="$LOG_DIR/http_headers_${domain}_${timestamp}_log"

    echo "[?] Kontrolujem hlavicky: $url"
    echo "[*] Log ukladam do: $log_file"
    echo

    # ziskame vsetky HTTP hlavicky jednym requestom
    local response
    response=$(curl -s -D - -o /dev/null "$url") || {
        echo "[-] Chyba pri pristupe na $url"
        return 1
    }

    # hlavicka log suboru (metadata scanu)
    {
        echo "=============================="
        echo "HTTP Security Headers Scan"
        echo "Target: $url"
        echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "=============================="
        echo
    } > "$log_file"

    # nacitanie zoznamu hlaviciek zo suboru do pola headers[]
    mapfile -t headers < "$HEADERS_FILE"

    # kontrola kazdej hlavicky
    for header in "${headers[@]}"; do
        # vyhladanie hodnoty hlavicky (case-insensitive)
        value=$(echo "$response" | grep -i "^$header:" | sed 's/^.*: //')

        if [[ -n "$value" ]]; then
            echo "[+] [$header] $value" | tee -a "$log_file"
        else
            echo "[-] [$header] Nenajdene" | tee -a "$log_file"
        fi
    done
}

# vyber URL
echo "[*] Zvol URL na testovanie:"
echo "[a] UKF Webmail"
echo "[b] UKF AiS"
read -rp "Moznost: " churl

case "$churl" in
    a) url="https://studentmail.ukf.sk/webmail/" ;;
    b) url="https://ais2.ukf.sk/ais/start.do" ;;
    *) echo "[-] Nespravna volba"; exit 1 ;;
esac

# spustenie kontroly
check_headers "$url"
