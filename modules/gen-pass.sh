#!/usr/bin/env bash

echo "[*] Zadaj prefix hesla (presne 6 cislic):"
read -p "Prefix: " prefix

# overenie 6 cislic pomocou regexu, =~ overuje match, ^ je zaciatok riadka a $ je koniec riadka, medzi nim overuje cisla od 0-9 a 6 cislic
if [[ ! "$prefix" =~ ^[0-9]{6}$ ]]; then
  echo "[!] Chyba: prefix musi obsahovat presne 6 cislic (0-9)."
  exit 1
fi

if [[ -e modules/passwords.txt ]]; then
  echo "[?] Chcete premazat existujuce hesla y/n ?"
  read wannadel
  if [[ "$wannadel" = "y" ]]; then
    > modules/passwords.txt
    echo "[+] Subor premazany"
  else
    touch modules/passwords.txt
    echo "[+] Pridavam dalsie hesla do suboru"
  fi
fi

for i in $(seq 0 9999); do
  potentionalPass="${prefix}${i}"
  # 10# zabezpeci aby cisla boli desiatkove, inak su osmickove
  if (( 10#$potentionalPass % 11 == 0 )); then
    echo "$potentionalPass" >> modules/passwords.txt
  fi
done

pocetHesiel=$(wc -l < modules/passwords.txt)
echo "[+] Hesla uspesne zapisane"
echo "[+] Pocet hesiel: $pocetHesiel"
