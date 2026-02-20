#!/usr/bin/env bash

# dynamicka absolutna cesta 
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

REQ_DIR="$BASE_DIR/requirements"
CHECK_DEPS="$REQ_DIR/check_dependencies.sh"

clear


# KONTROLA ZAVISLOSTI
if [[ -x "$CHECK_DEPS" ]]; then
    bash "$CHECK_DEPS"
else
    echo "[-] check_dependencies.sh nenajdeny alebo nema prava na spustenie"
    echo "[-] Skontroluj priecinok requirements/"
    exit 1
fi

sleep 3

# NAPOVEDA
show_help() {
    echo "Pouzitie: ./ikmu alebo bash ikmu"
    echo
    echo "  -h, --help       Zobrazi napovedu pouzitia nastroja"
    echo
    echo "Dostupne moduly:"
    echo "  1) Testovanie odozvy a Rate-limitingu"
    echo "  2) Generovat hesla"
    echo "  3) Brute-force na UKF Webmail"
    echo "  4) Brute-force na UKF AiS"
    echo "  5) Zistenie HTTP hlaviciek"
    echo "  6) Zistenie technologii"
    echo "  7) Zistenie IP adresy a polohy"
    echo "  8) Vyhlada zadane heslo v passwords.txt"
    echo "  9) Zistenie technologii (python verzia)"
    echo "  10) Mirrorovanie webovej stranky"
    echo "  h) Napoveda"
    echo "  x) Ukoncit nastroj"
    echo
}

# pocet modulov, v pripade dodatocnych modulov zacinajucich _ nepocita
count_modules() {
    find "$BASE_DIR/modules" -maxdepth 1 -type f \
        \( -name "*.sh" -o -name "*.py" \) \
        ! -name "_*" | wc -l
}

# pocet extended modulov
count_extended() {
    find "$BASE_DIR/modules/extended" -type f \
        \( -name "*.sh" -o -name "*.py" \) \
        ! -name "_*" | wc -l
}

# MENU
menu() {
    clear
    
    MODULES_COUNT=$(count_modules)
    EXTENDED_COUNT=$(count_extended)
    
    echo "###################################"
    echo "#           IKnowMyUni            #"
    echo "###################################"
    echo
    echo "IKMU - Web Application Penetration Testing Tool"
    echo "Author: Marian Hlavacka"
    echo "GitHub: https://github.com/majohlavacka/Diplomova-praca"
    echo
    echo "$MODULES_COUNT modules currently"
    echo "$EXTENDED_COUNT extended module(s) currently"
    echo
    echo "[*] Dostupne moznosti:"
    echo
    echo "[1] Testovanie odozvy a Rate-limitingu"
    echo "[2] Generovat hesla"
    echo "[3] Brute-force na UKF Webmail"
    echo "[4] Brute-force na UKF AiS"
    echo "[5] Zistenie HTTP hlaviciek"
    echo "[6] Zistenie technologii"
    echo "[7] Zistenie IP adresy a polohy"
    echo "[8] Hladat heslo vo vytvorenom zozname"
    echo "[9] Zistenie technologii (python verzia)"
    echo "[10] Mirror web stranky"
    echo "[h] Napoveda"
    echo "[x] Ukoncit nastroj"
    echo
    read -rp "[*] Moznost: " choice

    case "$choice" in
        1) "$BASE_DIR/modules/ping-uni.sh" ;;
        2) "$BASE_DIR/modules/gen-pass.sh" ;;
        3) "$BASE_DIR/modules/brute-webmail.py" ;;
        4) "$BASE_DIR/modules/brute-ais.py" ;;
        5) "$BASE_DIR/modules/http-headers.sh" ;;
        6) "$BASE_DIR/modules/tech-detect.sh" ;;
        7) "$BASE_DIR/modules/ip-info.sh" ;;
        8) "$BASE_DIR/modules/find-pass.sh" ;;
        9) "$BASE_DIR/modules/tech-detect.py" ;;
        10) "$BASE_DIR/modules/mirror-web.sh" ;;
        h|-h|--help) show_help ;;
        x) exit 0 ;;
        *)
            echo "Zadali ste nespravnu moznost."
            sleep 1
            ;;
    esac

    echo
    read -rp "Stlac ENTER pre navrat do menu..."
}

# PODPORA -h / --help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# HLAVNY LOOP
while true; do
    menu
done
