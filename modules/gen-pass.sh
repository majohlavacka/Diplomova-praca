#!/bin/bash

echo "Zadaj prefix"
read prefix

if [[ -e passwords.txt ]]; then
  echo "Chcete premazat existujuce hesla y/n ?"
  read wannadel
  if [[ "$wannadel" = "y" ]]; then
    > passwords.txt
  else
    touch passwords.txt
  fi
fi

for i in $(seq 0 9999); do
  potentionalPass="${prefix}${i}"
  if (( 10#$potentionalPass % 11 == 0 )); then
    echo "$potentionalPass" >> passwords.txt
  fi
done

pocetHesiel=$(cat passwords.txt | wc -l)
echo "Hesla uspesne zapisane. Pocet hesiel $pocetHesiel."
