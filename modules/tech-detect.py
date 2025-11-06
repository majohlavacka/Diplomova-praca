#!/usr/bin/env python3
import requests
import re
from bs4 import BeautifulSoup
import os

def choose_url():
    print("[*] Zvol URL na testovanie")
    print("[a] UKF Webmail")
    print("[b] UKF AiS")
    choice = input("Moznost: ").strip().lower()

    if choice == "a":
        return "https://studentmail.ukf.sk/webmail/"
    elif choice == "b":
        return "https://ais2.ukf.sk/ais/start.do"
    else:
        print("[-] Nespravna volba")
        exit(1)

def get_site_data(url):
    print(f"[?] Detekujem technologie na {url}")
    try:
        headers_resp = requests.head(url, allow_redirects=True, timeout=10)
        body_resp = requests.get(url, allow_redirects=True, timeout=10)
    except requests.RequestException as e:
        print(f"[-] Chyba: {e}")
        exit(1)

    return headers_resp.headers, body_resp.text

def detect_technologies(headers, body, url):
    print("\n[*] Analyza technologii hlavicky + HTML")

    # Web server 
    server = headers.get("Server", "").lower()
    if "nginx" in server:
        print("Web server: nginx")
    elif "apache" in server:
        print("Web server: Apache")
    elif "iis" in server:
        print("Web server: Microsoft IIS")

    # Backend
    backend_patterns = {
        "PHP": r"php|\.php|roundcube_sessid",
        "Java JSP/Servlet": r"jsp|java|jsessionid",
        "ASP.NET": r"asp\.net|\.aspx",
        "Node.js": r"node|express",
        "Python Django": r"django",
        "Python Flask": r"flask"
    }

    for name, pattern in backend_patterns.items():
        if re.search(pattern, headers.__str__() + body, re.I):
            print(f"Backend: {name}")
            break

    # CMS 
    cms_patterns = {
        "WordPress": r"wp-content|wordpress",
        "Drupal": r"drupal",
        "Joomla": r"joomla"
    }
    for name, pattern in cms_patterns.items():
        if re.search(pattern, body, re.I):
            print(f"CMS: {name}")
            break

    # PHP frameworky 
    php_frameworks = {
        "Laravel": r"laravel|csrf_token|XSRF-TOKEN",
        "Symfony": r"symfony",
        "CodeIgniter": r"codeigniter"
    }
    for name, pattern in php_frameworks.items():
        if re.search(pattern, body, re.I):
            print(f"Framework: {name}")
            break

    # Java frameworky 
    java_frameworks = {
        "Spring Java": r"spring",
        "Apache Struts": r"struts"
    }
    for name, pattern in java_frameworks.items():
        if re.search(pattern, body, re.I):
            print(f"Framework: {name}")
            break

    # Frontend / JS framework
    frontend_patterns = {
        "React": r"react|data-reactroot",
        "Angular": r"angular|ng-app",
        "Vue.js": r"vue|v-bind"
    }

    found_roundcube = False

    for name, pattern in frontend_patterns.items():
        if re.search(pattern, body, re.I):
            print(f"Frontend: {name}")
            break

    if re.search(r"rcmail\.set_env|roundcube_logo|rcube_webmail", body, re.I):
        print("Webmail klient: Roundcube")
        found_roundcube = True

    # Meta tag "generator" 
    soup = BeautifulSoup(body, "html.parser")
    for meta in soup.find_all("meta"):
        if meta.get("name", "").lower() == "generator":
            print(f"Generator: {meta.get('content')}")
            break

    # Roundcube extended modul 
    if found_roundcube:
        choice = input("\nChces overit klienta ? y/Y: ").strip().lower()
        if choice == "y":
            if os.path.isfile("extended/detect-round.sh"):
                print("[*] Extended modul na potvrdenie Roundcube")
                os.system(f"bash extended/detect-round.sh {url}")
            else:
                print("[-] Modul neexistuje")

def main():
    url = choose_url()
    headers, body = get_site_data(url)
    detect_technologies(headers, body, url)

if __name__ == "__main__":
    main()
