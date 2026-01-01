#!/usr/bin/env python3

import requests
import re
import os
import json
import sys
from datetime import datetime
from urllib.parse import urlparse

TIMEOUT = 10 # cakaj max 10 sekund ak server neodpovie

# absolutna cesta k tomuto modulu
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
LOG_DIR = os.path.join(BASE_DIR, "..", "logs")

# Roundcube heuristicke indikatory
ROUNDCUBE_INDICATORS = {
    "hard": [  # velmi silne dokazne znaky
        (r"rcmail\.set_env", 40),
        (r"roundcube_sess(id|auth)", 40),
        (r"X-Roundcube", 40),
    ],
    "medium": [  # typicke znaky
        (r"\?_task=(login|mail|settings)", 20),
        (r"skins/(elastic|classic)", 20),
        (r"rcube_webmail", 20),
    ],
    "weak": [  # doplnkove znaky
        (r"roundcube", 10),
        (r"webmail", 10),
    ],
}

CONFIRM_THRESHOLD = 60  # od kolkych percent povazujeme Roundcube za potvrdeny

# Confidence vypocet
def calculate_confidence(indicators, data):
    score = 0
    for pattern, weight in indicators:
        if re.search(pattern, data, re.I):
            score += weight
    return score

# Hlavna detekcia
def detect_roundcube(url):
    print(f"[*] Extended Roundcube analyza: {url}")

    try:
        head = requests.head(url, allow_redirects=True, timeout=TIMEOUT)
        get = requests.get(url, allow_redirects=True, timeout=TIMEOUT)
    except requests.RequestException as e:
        print(f"[-] Chyba spojenia: {e}")
        return None

    combined = str(head.headers) + get.text
    details = []
    total_score = 0

    # analyza indikatorov
    for level, indicators in ROUNDCUBE_INDICATORS.items():
        score = calculate_confidence(indicators, combined)
        if score > 0:
            total_score += score
            details.append({
                "level": level,
                "score": score
            })

    total_score = min(total_score, 100)
    confirmed = total_score >= CONFIRM_THRESHOLD

    result = {
        "technology": "Roundcube Webmail",
        "confirmed": confirmed,
        "confidence": total_score,
        "details": details
    }

    return result

# JSON export do (logs/)
def export_json(url, result):
    os.makedirs(LOG_DIR, exist_ok=True)

    domain = urlparse(url).netloc
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    filename = os.path.join(LOG_DIR, f"roundcube_detect_{domain}_{timestamp}.json")

    data = {
        "target": url,
        "timestamp": datetime.now().isoformat(),
        "result": result
    }

    with open(filename, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=4)

    print(f"[*] Roundcube JSON vystup ulozeny do: {filename}")


def main():
    if len(sys.argv) != 2:
        print(f"[?] Pouzitie: {sys.argv[0]} <url>")
        exit(1)

    url = sys.argv[1]
    result = detect_roundcube(url)

    if not result:
        print("[-] Detekcia zlyhala")
        exit(1)

    print("\n[*] Vysledok Roundcube analyzy")
    print("--------------------------------")
    print(f"Potvrdene: {result['confirmed']}")
    print(f"Confidence: {result['confidence']}%")

    export_json(url, result)

if __name__ == "__main__":
    main()
