#!/usr/bin/env bash

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

PASS_FILE="$BASE_DIR/passwords.txt"

# funkcia na generovanie hesiel
generate_passwords() {
  local prefix="$1"
  local prefix_num=$((10#$prefix)) # 10# zabezpeci desiatkovu interpretaciu 

  { # blok zabezpeci rychle, naraz zapisanie hesiel do suboru - rychly sposob
    for ((i=0; i<10000; i++)); do
      local password=$(( prefix_num * 10000 + i )) # vytvori 10-ciferne cislo spojenim prefixu a suffixu
      (( password % 11 == 0 )) && printf "%010d\n" "$password"
    done
  } >> "$PASS_FILE"
}

read -rp "[*] Zadaj prefix hesla (presne 6 cislic): " prefix
echo

# validacia vstupu
[[ "$prefix" =~ ^[0-9]{6}$ ]] || { echo "[!] Chyba: prefix musi mat presne 6 cislic"; exit 1; }

# kontrola suboru
if [[ -f "$PASS_FILE" ]]; then
  read -rp "[?] Subor passwords.txt existuje. Chces ho premazat? (y/n): " choice
  [[ "$choice" =~ ^[yY]$ ]] && > "$PASS_FILE"
else
  touch "$PASS_FILE"
fi

# volanie funkcie
generate_passwords "$prefix"

echo
echo "[+] Generovanie dokoncene"
echo "[+] Pocet hesiel v subore: $(wc -l < "$PASS_FILE")"
