#!/usr/bin/env bash

echo "[*] Zvol URL na testovanie"
echo "[a] UKF Webmail"
echo "[b] UKF AiS"
read -p "Moznost: " churl

if [[ "$churl" = "a" ]]; then
  url="https://studentmail.ukf.sk/webmail/"
elif [[ "$churl" = "b" ]]; then
  url="https://ais2.ukf.sk/ais/start.do"
else
  echo "[-] Nespravna volba"
  exit 1
fi

echo "[?] Detekujem technologie na $url"

# Ziskanie hlaviciek a HTML obsahu
headers=$(curl -s -I -L "$url")
body=$(curl -s -L "$url")

if [ -z "$headers" ]; then
  echo "[-] Chyba: Nepodarilo sa ziskat hlavicky"
  exit 1
fi

echo
echo "[*] Analyza technologii hlavicky + HTML"

detect_technologies() {
  local headers="$1"
  local body="$2"

  # Web server
  if echo "$headers" | grep -iq "nginx"; then
    echo "Web server: nginx"
  elif echo "$headers" | grep -iq "apache"; then
    echo "Web server: Apache"
  elif echo "$headers" | grep -iq "IIS"; then
    echo "Web server: Microsoft IIS"
  fi

  # Backend
  if echo "$headers$body" | grep -Eiq "php|\.php|roundcube_sessid"; then
    echo "Backend: PHP"
  elif echo "$headers$body" | grep -Eiq "jsp|java|jsessionid"; then
    echo "Backend: Java JSP/Servlet"
  elif echo "$headers$body" | grep -Eiq "asp\.net|\.aspx"; then
    echo "Backend: ASPNET"
  elif echo "$headers$body" | grep -Eiq "node|express"; then
    echo "Backend: Nodejs"
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

  # PHP frameworky
  if echo "$body" | grep -Eiq "laravel|csrf_token|XSRF-TOKEN"; then
    echo "Framework: Laravel"
  elif echo "$body" | grep -Eiq "symfony"; then
    echo "Framework: Symfony"
  elif echo "$body" | grep -Eiq "codeigniter"; then
    echo "Framework: CodeIgniter"
  fi

  # Java frameworky
  if echo "$body" | grep -Eiq "spring"; then
    echo "Framework: Spring Java"
  elif echo "$body" | grep -Eiq "struts"; then
    echo "Framework: Apache Struts"
  fi

  # Frontend / JS frameworks
  if echo "$body" | grep -Eiq "react|data-reactroot"; then
    echo "Frontend: React"
  elif echo "$body" | grep -Eiq "angular|ng-app"; then
    echo "Frontend: Angular"
  elif echo "$body" | grep -Eiq "vue|v-bind"; then
    echo "Frontend: Vuejs"
  elif echo "$body" | grep -Eiq "rcmail\.set_env|roundcube_logo|rcube_webmail"; then
    echo "Webmail klient: Roundcube"
    echo

    # Ponuka zavolania overenia cez extended modul
    read -p "Chces overit klienta ? y/Y " choice
    if [[ "$choice" = "y" || "$choice" = "Y" ]]; then
      if [ -f "extended/detect-round.sh" ]; then
        echo "[*] Extended modul na potvrdenie Roundcube"
        bash extended/detect-round.sh "$url"
      else
        echo "[-] Modul neexistuje"
      fi
    fi
  fi
}

detect_technologies "$headers" "$body"