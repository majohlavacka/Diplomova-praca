#!/bin/bash

echo "[*] Zvol URL na testovanie:"
echo "[a] UKF Webmail"
echo "[b] UKF AiS"
read -p "Moznost: " domcho

if [[ "$domcho" == "a" ]]; then
    url="studentmail.ukf.sk"
elif [[ "$domcho" == "b" ]]; then
    url="ais2.ukf.sk"
else
    echo "[-] Nespravna volba"
    exit 1
fi

echo "[?] Zistenie informacii pre $url"
echo "-------------------------"

IP=$(dig +short "$url" | head -n 1)
echo "[+] IP adresa: $IP"
echo "-------------------------"

curl "ipinfo.io/$IP"
echo
