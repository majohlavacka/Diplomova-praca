#!/bin/bash

echo "[*] Zadaj URL na testovanie:"
echo "[a] UKF Webmail"
echo "[b] UKF AiS"
read -p "Moznost: " churl

if [[ "$churl" = "a" ]]; then
  url="https://studentmail.ukf.sk/webmail/"
elif [[ "$churl" = "b" ]]; then
  url="https://ais2.ukf.sk/ais/start.do"
else
  echo "[-] Nespravna volba"
  exit 1
fi

echo "[?] Detekujem technologie"
headers=$(curl -s -I "$url")

echo "[+] $headers" | egrep -i "Server:|X-Powered-By|Set-Cookie:"

if echo "$headers" | grep -iq "wordpress"; then
    echo "[+] Detekovany WordPress"
fi

if echo "$headers" | grep -iq "php"; then
    echo "[+] Pravdepodobnost PHP"
fi

if echo "$headers" | grep -iq "nginx"; then
    echo "[+] Server bezi na nginx"
elif echo "$headers" | grep -iq "apache"; then
    echo "[+] Server bezi na Apache"
fi

