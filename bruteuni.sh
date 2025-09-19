#!/bin/bash

clear

show_help() {
    echo "Pouzitie: ./bruni alebo bash bruni"
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

# support ./bruteuni -h/--help 
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
fi

# menu
echo "###################################"
echo "#           IKnowMyUni            #"
echo "###################################"
echo "Vyberte moznost"
echo "a = Testovanie odozvy a Rate-limitingu"
echo "b = Generovat hesla"
echo "c = Brute-force na UKF Webmail"
echo "d = Brute-force na UKF AiS"
echo "e = Zistenie HTTP hlaviciek"
echo "f = Zistenie technologii"
echo "g = Zistenie IP adresy a polohy"
echo "i = Hladat heslo vo vytvorenom zozname"
echo "h = Napoveda"
echo "x = Ukoncit nastroj"


read -p "Moznost: " choice

case "$choice" in
  a) modules/ping-uni.sh ;;
  b) modules/gen-pass.sh ;;
  c) python3 modules/brute-webmail.py ;;
  d) modules/brute-ais.py ;;
  e) modules/http-headers.sh ;;
  f) modules/tech-detect.sh ;;
  g) modules/ip-info.sh ;;
  i) modules/find-pass.sh ;;
  h|-h|--help) show_help ;;   
  x) exit 0 ;;
  *) echo "Zadali ste nespravnu moznost. Koniec programu."; exit 1 ;;
esac
