#!/usr/bin/env bash
set -e

echo "Nastavujem spustitelne prava..."

find . -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod u+x {} +

echo
echo "Dokoncene!"
echo "Spustite: ./ikmu.sh"