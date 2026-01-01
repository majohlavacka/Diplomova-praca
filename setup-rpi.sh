#!/usr/bin/env bash
set -e

echo "Pripravujem prostredie (Raspberry Pi)..."

if ! command -v dos2unix >/dev/null 2>&1; then
    echo "Instalujem dos2unix..."
    sudo apt update
    sudo apt install -y dos2unix
fi

echo "Konvertujem konce riadkov na Unix..."
find . -type f \( -name "*.sh" -o -name "*.py" \) -exec dos2unix {} +

echo "Nastavujem spustitelne prava..."
find . -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod u+x {} +

echo
echo "Dokoncene!"
echo "Spustite: ./ikmu.sh"
