#!/usr/bin/env bash

# dynamicka cesta k nastroju
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

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
    echo "  j) Zistenie technologii (python verzia)"
    echo "  k) Mirrorovanie webovej stranky"
    echo "  x) Ukoncit nastroj"
    echo
}

menu() {
    clear
    echo "###################################"
    echo "#           IKnowMyUni            #"
    echo "###################################"
    echo
    echo "IKMU - Web Application Penetration Testing Tool"
    echo "Author: Marian Hlavacka"
    echo "GitHub: https://github.com/majohlavacka/Diplomova-praca"
    echo
    echo "10 modules currently"
    echo "1 extended modules currently"
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
    echo "[j] Zistenie technologii (python verzia)"
    echo "[k] Mirror web stranky"
    echo "[h] Napoveda"
    echo "[x] Ukoncit nastroj"
    echo
    read -p "[*] Moznost: " choice

    case "$choice" in
        a) bash "$BASE_DIR/modules/ping-uni.sh" ;;
        b) bash "$BASE_DIR/modules/gen-pass.sh" ;;
        c) python3 "$BASE_DIR/modules/brute-webmail.py" ;;
        d) python3 "$BASE_DIR/modules/brute-ais.py" ;;
        e) bash "$BASE_DIR/modules/http-headers.sh" ;;
        f) bash "$BASE_DIR/modules/tech-detect.sh" ;;
        g) bash "$BASE_DIR/modules/ip-info.sh" ;;
        i) bash "$BASE_DIR/modules/find-pass.sh" ;;
        j) python3 "$BASE_DIR/modules/tech-detect.py" ;;
        k) bash "$BASE_DIR/modules/mirror-web.sh" ;;
        h|-h|--help) show_help ;;
        x) exit 0 ;;
        *) 
            echo "Zadali ste nespravnu moznost."
            sleep 1
            ;;
    esac

    echo
    read -p "Stlac ENTER pre navrat do menu..."
}

# podpora ./ikmu -h / --help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# hlavny loop menu
while true; do
    menu
done
