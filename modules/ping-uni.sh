#!/usr/bin/env bash

echo "[*] Zvol URL na testovanie:"
echo "[a] UKF Webmail"
echo "[b] UKF AiS"
echo
read -p "Moznost: " ch

if [[ "$ch" = "a" ]]; then
    url="https://studentmail.ukf.sk/webmail/"
elif [[ "$ch" = "b" ]]; then
    url="https://ais2.ukf.sk/ais/start.do"
else
    echo "[-] Neplatna volba."
    exit 1
fi

read -p "[*] Zadajte pocet poziadaviek: " rq 
for i in $(seq 1 "$rq"); do
    echo "[?] ${i}. Poziadavka..."
    response=$(curl -o /dev/null -s -w "Kod: %{http_code}, Cas: %{time_total}\n" "$url")
    echo "$response"
    sleep 2
done

