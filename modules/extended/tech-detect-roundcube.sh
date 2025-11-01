#!/usr/bin/env bash

URL="$1"

if [ -z "$URL" ]; then
  echo "[?] Pouzitie: $0 https://studentmail.ukf.sk/webmail/"
  exit 1
fi

found=0 # Flag

echo "[*] Kontrolujem URL: $URL"

# Skontroluj cookies
cookies=$(curl -s -L -I "$URL" | grep -i 'Set-Cookie')
if echo "$cookies" | grep -iq "roundcube_sessid"; then
  echo "[+] Cookie naznacuje Roundcube"
  found=1
fi

# Získaj HTML hlavnej stránky
html=$(curl -s -L "$URL")

# Extrahuj endpointy s ?_task=
endpoints=$(echo "$html" | grep -Eo '(\?_task=[a-zA-Z0-9_]+)' | sort -u)

# Ak sa nič nenašlo, aspoň skúsi základný
if [ -z "$endpoints" ]; then
  endpoints=""
fi

# Prejdi všetky endpointy
for endpoint in $endpoints; do
  full_url="${URL}${endpoint}"
  resp=$(curl -s -L "$full_url")
  if echo "$resp" | grep -Eiq "rcmail|roundcube_logo|rcube_webmail|rcmail.set_env"; then
    echo "[+] Roundcube rozpoznany na endpointe: $full_url"
    found=1
    break
  fi
done

# Skontroluj specificke hlavicky
headers=$(curl -s -I "$URL")
if echo "$headers" | grep -Eiq "X-Roundcube-Request|X-Roundcube-Token|X-Roundcube-Session|X-Roundcube-Version|X-Powered-By: Roundcube"; then
  echo "[+] Roundcube hlavicka najdena"
  found=1
fi

if [ "$found" -eq 0 ]; then
  echo "[-] *--* Roundcube nepotvrdeny *--*"
else
  echo "[+] *--* Roundcube potvrdeny *--*"
fi