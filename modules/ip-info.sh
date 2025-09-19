#!/bin/bash

echo "Zvol ktoru domenu chces testovat"
echo "a - UKF Webmail"
echo "b - UKF AiS"
read domcho

if [[ "$domcho" == "a" ]]; then
    url="https://studentmail.ukf.sk/webmail/"
elif [[ "$domcho" == "b" ]]; then
    url="https://ais2.ukf.sk/ais/start.do"
else
    echo "Nespravna volba"
    exit 1
fi

echo "Zistenie informacii pre $url"
echo "-------------------------"

IP=$(dig +short "$url" | head -n 1)
echo "IP adresa: $IP"
echo "-------------------------"

curl "ipinfo.io/$IP"
echo
