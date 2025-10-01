#!/usr/bin/env bash

clear

show_help() {
    echo "Pouzitie: ./ikmu alebo bash ikmu"
    echo ""
    echo "  -h, --help       Zobrazi napovedu pouzitia nastroja"
    echo ""
    echo "Dostupne moduly:"
    echo "  a) Testovanie odozvy a Rate-limitingu"
    echo "  b) Generovat hesla"
    echo "  c) Brute-force na UKF Webmail"
    echo "  d) Brute-force na UKF AiS"
    echo "  e) Zistenie HTTP hlaviciek"
    echo "  f) Zistenie technologii"
    echo "  g) Zistenie IP adresy a polohy"
    echo "  i) Vyhlada zadane heslo v passwords.txt"
    echo "  x) Ukoncit nastroj"
    echo
    exit 0
}

menu() {
    echo "###################################"
    echo "#           IKnowMyUni            #"
    echo "###################################"
    echo
    echo "[*] Dostupne moznosti:"
    echo
    echo "[a] Testovanie odozvy a Rate-limitingu"
    echo "[b] Generovat hesla"
    echo "[c] Brute-force na UKF Webmail"
    echo "[d] Brute-force na UKF AiS"
    echo "[e] Zistenie HTTP hlaviciek"
    echo "[f] Zistenie technologii"
    echo "[g] Zistenie IP adresy a polohy"
    echo "[i] Hladat heslo vo vytvorenom zozname"
    echo "[h] Napoveda"
    echo "[x] Ukoncit nastroj"
    echo
    read -p "[*] Moznost: " choice

    case "$choice" in
        a) /home/kali/diplom/modules/ping-uni.sh ;;
        b) /home/kali/diplom/modules/gen-pass.sh ;;
        c) python3 /home/kali/diplom/modules/brute-webmail.py ;;
        d) python3 /home/kali/diplom/modules/brute-ais.py ;;
        e) /home/kali/diplom/modules/http-headers.sh ;;
        f) /home/kali/diplom/modules/tech-detect.sh ;;
        g) /home/kali/diplom/modules/ip-info.sh ;;
        i) /home/kali/diplom/modules/find-pass.sh ;;
        h|-h|--help) show_help ;;
        x) exit 0 ;;
        *) echo "Zadali ste nespravnu moznost. Koniec programu."; exit 1 ;;
    esac
}

# support ./ikmu -h/--help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
fi

# zavolanie menu
menu

