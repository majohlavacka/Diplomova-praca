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

# Skontroluj typicke endpointy
for endpoint in "" "?_task=login" "?_task=mail" "?_task=logout"; do
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
