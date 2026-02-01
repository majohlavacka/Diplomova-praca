#!/usr/bin/env python3

import requests
import re
import os
import json
from datetime import datetime
from bs4 import BeautifulSoup
from urllib.parse import urlparse

TIMEOUT = 10 # ak server neodpovie do 10 sekund, vyhodi sa vynimka requests.RequestException

# absolutna cesta k adresaru skriptu
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
LOG_DIR = os.path.join(BASE_DIR, "logs")

# URL selection
def choose_url():
    print("[*] Zvol URL na testovanie")
    print("[a] UKF Webmail")
    print("[b] UKF AiS")
    choice = input("Moznost: ").strip().lower()

    # vyber URL podla volby
    match choice:
        case "a":
            return "https://studentmail.ukf.sk/webmail/"
        case "b":
            return "https://ais2.ukf.sk/ais/start.do"
        case _:
            print("[-] Nespravna volba")
            exit(1)

# HTTP data retrieval
def get_site_data(url):
    print(f"\n[?] Detekujem technologie na: {url}")

    # HEAD pre hlavicky, GET pre HTML
    try:
        head = requests.head(url, allow_redirects=True, timeout=TIMEOUT)
        get = requests.get(url, allow_redirects=True, timeout=TIMEOUT)
    except requests.RequestException as e:
        print(f"[-] Chyba: {e}")
        exit(1)

    return head.headers, get.text

# Confidence scoring
def calculate_confidence(indicators, data):
    score = 0
    for pattern, weight in indicators:
        # ak sa pattern najde, pripocitaj score
        if re.search(pattern, data, re.I):
            score += weight
    return min(score, 100)  # max 100%

# Technology definitions (slovnik)
TECH_DEFINITIONS = {
    # Backend
    "Backend: PHP": [
        (r"\.php", 40),              # URL konci na .php
        (r"php", 20),                # zmienka o PHP v hlavickach
        (r"roundcube_sessid", 40),   # Roundcube session cookie - PHP backend
    ],
    "Backend: Java (JSP/Servlet)": [
        (r"jsp", 40),                # JSP subory
        (r"jsessionid", 60),         # Java session cookie
    ],
    "Backend: ASP.NET": [
        (r"asp\.net", 50),           # ASP.NET indikatory
        (r"\.aspx", 50),             # ASPX subory
    ],
    "Backend: Node.js": [
        (r"node", 50),               # Node.js zmienky v HTML alebo hlavickach
        (r"express", 50),            # Express framework
    ],

    # Python frameworky
    "Framework: Laravel": [
        (r"csrf_token", 40),         # Laravel CSRF token
        (r"XSRF-TOKEN", 40),         # Laravel cookie/XSRF
        (r"laravel", 20),            # zmienky v HTML
    ],
    "Framework: Symfony": [
        (r"symfony", 100),           # Symfony indikatory
    ],
    "Framework: CodeIgniter": [
        (r"codeigniter", 100),       # CodeIgniter indikatory
    ],
    "Framework: Spring": [
        (r"spring", 50),             # Spring Java zmienky
        (r"jsessionid", 50),         # Java session cookie
    ],

    # CMS
    "CMS: WordPress": [
        (r"wp-content", 60),         # standardna WordPress struktura
        (r"wordpress", 40),          # meta generator alebo HTML zmienky
    ],
    "CMS: Drupal": [
        (r"drupal", 100),            # Drupal HTML/URL zmienky
    ],
    "CMS: Joomla": [
        (r"joomla", 100),            # Joomla HTML/URL zmienky
    ],

    # Frontend / JS framework
    "Frontend: React": [
        (r"data-reactroot", 70),     # identifikator React root element
        (r"react", 30),              # dalsie zmienky v JS/HTML
    ],
    "Frontend: Angular": [
        (r"ng-app", 60),             # Angular aplikacia
        (r"angular", 40),            # dalsie zmienky
    ],
    "Frontend: Vue.js": [
        (r"vue", 50),                # Vue.js indikatory
        (r"v-bind", 50),             # Vue direktivy
    ],
}

# Roundcube specialne indikatory
ROUNDCUBE_INDICATORS = [
    (r"rcmail\.set_env", 40),        # JS inicializacia Roundcube
    (r"roundcube_logo", 30),         # logo
    (r"rcube_webmail", 30),          # dalsie zmienky
]

# Detection logic
def detect_technologies(headers, body, url):
    combined = str(headers) + body
    results = []

    print("\n[*] Analyza technologii (confidence score)")
    print("-----------------------------------------")

    # detekcia web servera z hlaviciek
    server = headers.get("Server", "").lower()
    if server:
        if "nginx" in server:
            results.append({"type": "Web server", "name": "nginx", "confidence": 100})
        elif "apache" in server:
            results.append({"type": "Web server", "name": "Apache", "confidence": 100})
        elif "iis" in server:
            results.append({"type": "Web server", "name": "Microsoft IIS", "confidence": 100})

    # detekcia technologii podla patternov
    for tech, indicators in TECH_DEFINITIONS.items():
        score = calculate_confidence(indicators, combined)
        if score > 0:
            category, name = tech.split(": ", 1)
            results.append({
                "type": category,
                "name": name,
                "confidence": score
            })

    # Roundcube
    rc_score = calculate_confidence(ROUNDCUBE_INDICATORS, body)
    found_roundcube = False
    if rc_score > 0:
        found_roundcube = True
        results.append({
            "type": "Webmail",
            "name": "Roundcube",
            "confidence": rc_score
        })

    # meta tag generator (napr. WordPress)
    soup = BeautifulSoup(body, "html.parser")
    for meta in soup.find_all("meta"):
        if meta.get("name", "").lower() == "generator":
            results.append({
                "type": "Meta",
                "name": "Generator",
                "value": meta.get("content")
            })
            break

    # vypis vysledkov
    for item in results:
        if "confidence" in item:
            print(f"{item['type']}: {item['name']} (confidence: {item['confidence']}%)")
        else:
            print(f"{item['type']}: {item['name']} = {item['value']}")

    return results, found_roundcube

# JSON export (do logs/)
def export_json(url, results):
    # vytvorenie log adresara
    os.makedirs(LOG_DIR, exist_ok=True)

    domain = urlparse(url).netloc
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    filename = os.path.join(LOG_DIR, f"tech_detect_{domain}_{timestamp}.json")

    data = {
        "target": url,
        "timestamp": datetime.now().isoformat(),
        "technologies": results
    }

    with open(filename, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=4)

    print(f"\n[*] JSON vystup ulozeny do: {filename}")

# Main
def main():
    url = choose_url()
    headers, body = get_site_data(url)
    results, found_roundcube = detect_technologies(headers, body, url)
    export_json(url, results)

    # volitelne spustenie extended Roundcube modulu, ak sa nasiel
    if found_roundcube:
        choice = input("\nChces overit Roundcube detailne? (y/n): ").strip().lower()
        if choice == "y":
            extended_path = os.path.join(BASE_DIR, "extended", "detect-round.py")
            if os.path.isfile(extended_path):
                print("[*] Spustam extended modul detect-round.py")
                os.system(f"python3 {extended_path} {url}")
            else:
                print("[-] Extended modul neexistuje")

if __name__ == "__main__":
    main()
