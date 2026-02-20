#!/usr/bin/env bash

select_target() {
    echo "[*] Zvol ciel:"
    echo "[1] UKF Webmail"
    echo "[2] UKF AiS"
    echo
    read -rp "Moznost: " choice

    case "$choice" in
        1)
            TARGET_URL="https://studentmail.ukf.sk/webmail/"
            ;;
        2)
            TARGET_URL="https://ais2.ukf.sk/ais/start.do"
            ;;
        *)
            echo "[-] Nespravna volba"
            return 1
            ;;
    esac

    export TARGET_URL
}
