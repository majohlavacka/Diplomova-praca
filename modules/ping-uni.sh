#!/bin/bash

echo "Zvolte ktoru domenu chcete pingovat:"
echo "a = UKF Webmail"
echo "b = UKF AiS"
read ch

if [[ "$ch" = "a" ]]; then
    url="https://studentmail.ukf.sk/webmail/"
elif [[ "$ch" = "b" ]]; then
    url="https://ais2.ukf.sk/ais/start.do"
else
    echo "Neplatna volba."
    exit 1
fi

for i in $(seq 1 5); do
    echo "${i}. Poziadavka..."
    response=$(curl -o /dev/null -s -w "Kod: %{http_code}, Cas: %{time_total}\n" "$url")
    echo "$response"
    sleep 2
done
