#!/usr/bin/env bash

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# adresar pre logy
LOG_DIR="$BASE_DIR/logs"

# vytvorenie logs/ ak neexistuje
mkdir -p "$LOG_DIR"

# funkcia na zistenie IP informacii
check_ip_info() {
    local domain="$1"

    # timestamp pre unikatny nazov log suboru
    local timestamp
    timestamp=$(date '+%Y-%m-%d_%H-%M-%S')

    # nazov log suboru
    local log_file="$LOG_DIR/ip_info_${domain}_${timestamp}_log"

    echo "[?] Zistujem IP informacie pre: $domain"
    echo "[*] Log ukladam do: $log_file"
    echo

    # ziskanie IP adresy
    local ip
    ip=$(dig +short "$domain" | head -n 1)

    if [[ -z "$ip" ]]; then
        echo "[-] Nepodarilo sa ziskat IP adresu"
        return 1
    fi

    # hlavicka log suboru (metadata scanu)
    {
        echo "=============================="
        echo "IP Information Scan"
        echo "Target: $domain"
        echo "IP Address: $ip"
        echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "=============================="
        echo
    } > "$log_file"

    echo "[+] IP adresa: $ip" | tee -a "$log_file"
    echo "------------------------------" | tee -a "$log_file"

    # ziskanie informacii z ipinfo.io
    curl -s "https://ipinfo.io/$ip" | tee -a "$log_file"
    echo
}

echo "[*] Zvol URL na testovanie:"
echo "[a] UKF Webmail"
echo "[b] UKF AiS"
read -rp "Moznost: " domcho

case "$domcho" in
    a) domain="studentmail.ukf.sk" ;;
    b) domain="ais2.ukf.sk" ;;
    *) echo "[-] Nespravna volba"; exit 1 ;;
esac

check_ip_info "$domain"