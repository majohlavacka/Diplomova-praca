#!/usr/bin/env bash

echo "[*] Zvol URL na testovanie"
echo "[a] UKF Webmail"
echo "[b] UKF AiS"
read -rp "Moznost: " churl

case "$churl" in
  a) url="https://studentmail.ukf.sk/webmail/" ;;
  b) url="https://ais2.ukf.sk/ais/start.do" ;;
  *) echo "[-] Nespravna volba"; exit 1 ;;
esac

echo
echo "[?] Detekujem technologie na: $url"

# ziskanie hlaviciek a HTML obsahu (2 requesty)
headers=$(curl -s -I -L --max-time 10 "$url")
body=$(curl -s -L --max-time 10 "$url")

if [[ -z "$headers" ]]; then
  echo "[-] Chyba: nepodarilo sa ziskat hlavicky"
  exit 1
fi

echo
echo "[*] Analyza technologii (HTTP hlavicky + HTML)"
echo "--------------------------------------------"

detect_technologies() {
  local headers="$1"
  local body="$2"

  # === WEB SERVER ===
  if echo "$headers" | grep -iq "nginx"; then
    echo "Web server: nginx"
  elif echo "$headers" | grep -iq "apache"; then
    echo "Web server: Apache"
  elif echo "$headers" | grep -iq "IIS"; then
    echo "Web server: Microsoft IIS"
  fi

  # BACKEND 
  if echo "$headers$body" | grep -Eiq "php|\.php|roundcube_sessid"; then
    echo "Backend: PHP"
  elif echo "$headers$body" | grep -Eiq "jsp|jsessionid"; then
    echo "Backend: Java (JSP/Servlet)"
  elif echo "$headers$body" | grep -Eiq "asp\.net|\.aspx"; then
    echo "Backend: ASP.NET"
  elif echo "$headers$body" | grep -Eiq "node|express"; then
    echo "Backend: Node.js"
  elif echo "$headers$body" | grep -Eiq "django"; then
    echo "Backend: Python Django"
  elif echo "$headers$body" | grep -Eiq "flask"; then
    echo "Backend: Python Flask"
  fi

  # CMS 
  if echo "$body" | grep -Eiq "wp-content|wordpress"; then
    echo "CMS: WordPress"
  elif echo "$body" | grep -Eiq "drupal"; then
    echo "CMS: Drupal"
  elif echo "$body" | grep -Eiq "joomla"; then
    echo "CMS: Joomla"
  fi

  # PHP FRAMEWORKY 
  if echo "$body" | grep -Eiq "laravel|csrf_token|XSRF-TOKEN"; then
    echo "Framework: Laravel"
  elif echo "$body" | grep -Eiq "symfony"; then
    echo "Framework: Symfony"
  elif echo "$body" | grep -Eiq "codeigniter"; then
    echo "Framework: CodeIgniter"
  fi

  # JAVA FRAMEWORKY 
  if echo "$body" | grep -Eiq "spring"; then
    echo "Framework: Spring"
  elif echo "$body" | grep -Eiq "struts"; then
    echo "Framework: Apache Struts"
  fi

  # FRONTEND / WEBMAIL
  if echo "$body" | grep -Eiq "react|data-reactroot"; then
    echo "Frontend: React"
  elif echo "$body" | grep -Eiq "angular|ng-app"; then
    echo "Frontend: Angular"
  elif echo "$body" | grep -Eiq "vue|v-bind"; then
    echo "Frontend: Vue.js"
  elif echo "$body" | grep -Eiq "rcmail\.set_env|roundcube_logo|rcube_webmail"; then
    echo "Webmail klient: Roundcube"
    echo

    read -rp "Chces overit Roundcube detailne? (y/n): " choice
    if [[ "$choice" =~ ^[yY]$ ]]; then
      if [[ -f "extended/detect-round.sh" ]]; then
        echo "[*] Spustam extended modul detect-round.sh"
        bash extended/detect-round.sh "$url"
      else
        echo "[-] Extended modul neexistuje"
      fi
    fi
  fi
}

detect_technologies "$headers" "$body"
