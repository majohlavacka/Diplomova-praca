#!/usr/bin/env bash

select_target() {
    echo "[*] Zvol ciel:"
    echo "[a] UKF Webmail"
    echo "[b] UKF AiS"
    echo
    read -rp "Moznost: " choice

    case "$choice" in
        a)
            TARGET_URL="https://studentmail.ukf.sk/webmail/"
            ;;
        b)
            TARGET_URL="https://ais2.ukf.sk/ais/start.do"
            ;;
        *)
            echo "[-] Nespravna volba"
            return 1
            ;;
    esac

    export TARGET_URL
}
