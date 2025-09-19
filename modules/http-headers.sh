#!/bin/bash

echo "Zadaj ktoru url chces testovat"
echo "a = UKF Webmail"
echo "b = UKF AiS"
read churl

if [[ "$churl" = "a" ]]; then
  url="https://studentmail.ukf.sk/webmail/"
elif [[ "$churl" = "b" ]]; then
  url="https://ais2.ukf.sk/ais/start.do"
else
  echo "Nespravna volba"
  exit 1
fi

echo "Kontrolujem hlavicky: $url"
response=$(curl -s -D - -o /dev/null "$url")

headers=("Content-Security-Policy" "Strict-Transport-Security" "X-Content-Type-Options" "X-Frame-Options" "Referrer-Policy" "Permissions-Policy" "X-XSS-Protection")

for header in "${headers[@]}"; do
  if echo "$response" | grep -i "$header" > /dev/null; then
     value=$(echo "$response" | grep -i "$header")
     echo "[+][$header] Najdene: $value"
  else
     echo "[-][$header] Nenajdene"
  fi
done
