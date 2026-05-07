#!/usr/bin/env bash
# ================================================================
#   PABLO CYBER — OSINT TOOLKIT v1.0
#   Ferramenta educacional de reconhecimento passivo
#   Uso apenas em alvos com autorização explícita
# ================================================================

# ── Cores ────────────────────────────────────────────────────────
R='\033[0;31m'   # vermelho
G='\033[0;32m'   # verde
Y='\033[1;33m'   # amarelo
B='\033[0;34m'   # azul
C='\033[0;36m'   # ciano
M='\033[0;35m'   # magenta
W='\033[1;37m'   # branco negrito
D='\033[2;37m'   # cinza
NC='\033[0m'     # reset
BOLD='\033[1m'
BLINK='\033[5m'

# ── Verificação de dependências ──────────────────────────────────
check_deps() {
    local deps=("curl" "dig" "whois" "nmap" "nslookup" "host" "jq")
    local missing=()
    for d in "${deps[@]}"; do
        command -v "$d" &>/dev/null || missing+=("$d")
    done
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${Y}[!] Dependências ausentes: ${missing[*]}${NC}"
        echo -e "${D}    Instale com: sudo apt install ${missing[*]}${NC}"
    fi
}

# ── Banner principal ─────────────────────────────────────────────
banner() {
    clear
    echo -e "${R}"
    cat << 'EOF'
██████╗  █████╗ ██████╗ ██╗      ██████╗      ██████╗██╗   ██╗██████╗ ███████╗██████╗
██╔══██╗██╔══██╗██╔══██╗██║     ██╔═══██╗    ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗
██████╔╝███████║██████╔╝██║     ██║   ██║    ██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝
██╔═══╝ ██╔══██║██╔══██╗██║     ██║   ██║    ██║       ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗
██║     ██║  ██║██████╔╝███████╗╚██████╔╝    ╚██████╗   ██║   ██████╔╝███████╗██║  ██║
╚═╝     ╚═╝  ╚═╝╚═════╝ ╚══════╝ ╚═════╝      ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝
EOF
    echo -e "${NC}"
    echo -e "${D}              ════════════════════════════════════════════${NC}"
    echo -e "${C}                    OSINT & Reconhecimento Passivo${NC}"
    echo -e "${D}              ════════════════════════════════════════════${NC}"
    echo -e "${Y}                         by Pablo Cyber v1.0${NC}"
    echo -e "${D}              ════════════════════════════════════════════${NC}"
    echo ""
}

# ── Separador ────────────────────────────────────────────────────
sep() { echo -e "${D}  ──────────────────────────────────────────────────────${NC}"; }
header() { echo -e "\n${M}  ╔══ ${W}${1}${M} ══╗${NC}\n"; }
ok()  { echo -e "  ${G}[✔]${NC} ${1}"; }
inf() { echo -e "  ${C}[i]${NC} ${1}"; }
wrn() { echo -e "  ${Y}[!]${NC} ${1}"; }
err() { echo -e "  ${R}[✖]${NC} ${1}"; }
lnk() { echo -e "  ${B}[→]${NC} ${C}${1}${NC}"; }

# ── Pausa ────────────────────────────────────────────────────────
pause() {
    echo ""
    read -rp "$(echo -e "  ${D}Pressione ENTER para continuar...${NC}")"
}

# ── Input seguro ─────────────────────────────────────────────────
get_input() {
    local label="$1"
    echo -ne "  ${G}►${NC} ${W}${label}:${NC} "
    read -r INPUT
    echo "$INPUT"
}

# ════════════════════════════════════════════════════════════════
#  MÓDULO 1 — EMAIL → CONTAS REGISTRADAS
# ════════════════════════════════════════════════════════════════
mod_email_accounts() {
    header "EMAIL → CONTAS REGISTRADAS"
    local email
    email=$(get_input "Digite o email")
    [[ -z "$email" || ! "$email" =~ @ ]] && err "Email inválido." && pause && return

    local domain="${email##*@}"
    sep
    inf "Alvo: ${W}${email}${NC}"
    inf "Domínio: ${W}${domain}${NC}"
    sep

    echo -e "\n  ${Y}[~] Gerando links de verificação...${NC}\n"
    sleep 0.5

    ok "Gravatar        → https://en.gravatar.com/$(echo -n "$email" | md5sum | cut -d' ' -f1)"
    ok "GitHub Search   → https://github.com/search?q=${email}&type=users"
    ok "HaveIBeenPwned  → https://haveibeenpwned.com/account/${email}"
    ok "LinkedIn        → https://www.linkedin.com/search/results/people/?keywords=${email}"
    ok "Google          → https://www.google.com/search?q=%22${email}%22"
    ok "Twitter/X       → https://twitter.com/search?q=${email}"
    ok "Skype (via MS)  → https://www.skype.com/en/features/"
    ok "Pastebin        → https://www.google.com/search?q=site:pastebin.com+%22${email}%22"

    sep
    echo -e "\n  ${Y}[~] Verificando DNS do domínio...${NC}"
    local mx
    mx=$(dig +short MX "$domain" 2>/dev/null | head -5)
    if [ -n "$mx" ]; then
        ok "Registros MX encontrados:"
        echo "$mx" | while read -r line; do
            echo -e "     ${D}${line}${NC}"
        done
    else
        wrn "Nenhum registro MX encontrado para ${domain}"
    fi

    sep
    wrn "Verifique manualmente cada link acima."
    pause
}

# ════════════════════════════════════════════════════════════════
#  MÓDULO 2 — GRAVATAR
# ════════════════════════════════════════════════════════════════
mod_gravatar() {
    header "GRAVATAR — BUSCA POR EMAIL"
    local email
    email=$(get_input "Digite o email")
    [[ -z "$email" || ! "$email" =~ @ ]] && err "Email inválido." && pause && return

    local clean_email
    clean_email=$(echo -n "${email,,}" | tr -d ' ')
    local hash
    hash=$(echo -n "$clean_email" | md5sum | cut -d' ' -f1)

    sep
    inf "Email:    ${W}${email}${NC}"
    inf "Hash MD5: ${W}${hash}${NC}"
    sep

    echo -e "\n  ${Y}[~] Consultando Gravatar...${NC}"
    local http_code
    http_code=$(curl -s -o /dev/null -w "%{http_code}" "https://www.gravatar.com/avatar/${hash}?d=404")

    if [ "$http_code" = "200" ]; then
        ok "${G}Conta Gravatar ENCONTRADA!${NC}"
        ok "Perfil:    https://en.gravatar.com/${hash}"
        ok "Avatar:    https://www.gravatar.com/avatar/${hash}?s=200"
        ok "JSON API:  https://en.gravatar.com/${hash}.json"
        echo ""
        echo -e "  ${Y}[~] Buscando dados JSON...${NC}"
        local json
        json=$(curl -s "https://en.gravatar.com/${hash}.json" 2>/dev/null)
        if [ -n "$json" ]; then
            local display_name
            display_name=$(echo "$json" | grep -o '"displayName":"[^"]*"' | cut -d'"' -f4)
            local profile_url
            profile_url=$(echo "$json" | grep -o '"profileUrl":"[^"]*"' | cut -d'"' -f4)
            [ -n "$display_name" ] && ok "Nome:      ${W}${display_name}${NC}"
            [ -n "$profile_url"  ] && ok "URL:       ${W}${profile_url}${NC}"
        fi
    elif [ "$http_code" = "404" ]; then
        err "Nenhuma conta Gravatar encontrada para este email."
    else
        wrn "Resposta inesperada (HTTP ${http_code}). Verifique manualmente."
        lnk "https://en.gravatar.com/${hash}"
    fi

    sep
    pause
}

# ════════════════════════════════════════════════════════════════
#  MÓDULO 3 — ENUMERAR EMAILS DO DOMÍNIO
# ════════════════════════════════════════════════════════════════
mod_email_enum() {
    header "ENUMERAR EMAILS DE UM DOMÍNIO"
    local domain
    domain=$(get_input "Digite o domínio (ex: empresa.com)")
    domain="${domain//http:\/\//}"
    domain="${domain//https:\/\//}"
    domain="${domain%%/*}"
    [[ -z "$domain" || ! "$domain" =~ \. ]] && err "Domínio inválido." && pause && return

    sep
    inf "Domínio alvo: ${W}${domain}${NC}"
    sep

    echo -e "\n  ${Y}[~] Padrões comuns de email corporativo:${NC}\n"
    local prefixes=("admin" "contato" "contact" "info" "suporte" "support"
                    "hello" "ola" "noreply" "no-reply" "security" "abuse"
                    "postmaster" "webmaster" "hostmaster" "rh" "hr" "sales"
                    "vendas" "marketing" "financeiro" "finance" "ti" "it"
                    "ceo" "cto" "coo" "help" "desk" "helpdesk")
    for p in "${prefixes[@]}"; do
        ok "${p}@${domain}"
    done

    sep
    echo -e "\n  ${C}[i] Fontes externas para verificação real:${NC}\n"
    lnk "https://hunter.io/search/${domain}"
    lnk "https://phonebook.cz/?search=${domain}"
    lnk "https://emailrep.io"
    lnk "https://intelx.io/?s=${domain}"
    lnk "https://www.google.com/search?q=site:${domain}+%22@${domain}%22"

    sep
    echo -e "\n  ${Y}[~] Verificando registros DNS...${NC}"
    local spf
    spf=$(dig +short TXT "$domain" 2>/dev/null | grep -i "spf" | head -2)
    if [ -n "$spf" ]; then
        ok "Registro SPF:"
        echo -e "     ${D}${spf}${NC}"
    fi

    local dmarc
    dmarc=$(dig +short TXT "_dmarc.${domain}" 2>/dev/null | head -1)
    if [ -n "$dmarc" ]; then
        ok "Registro DMARC:"
        echo -e "     ${D}${dmarc}${NC}"
    fi

    sep
    pause
}

# ════════════════════════════════════════════════════════════════
#  MÓDULO 4 — BUSCA POR NÚMERO DE TELEFONE
# ════════════════════════════════════════════════════════════════
mod_phone() {
    header "OSINT POR NÚMERO DE TELEFONE"
    local phone
    phone=$(get_input "Digite o número (com DDI, ex: +5511999998888)")
    [[ -z "$phone" ]] && err "Número vazio." && pause && return

    local clean_phone="${phone//[^0-9+]/}"
    sep
    inf "Número: ${W}${phone}${NC}"
    sep

    echo -e "\n  ${Y}[~] Links para verificação manual:${NC}\n"
    lnk "https://www.truecaller.com/search/br/${clean_phone//+/}"
    lnk "https://www.google.com/search?q=%22${clean_phone}%22"
    lnk "https://www.numverify.com"
    lnk "https://www.whocalledme.com"
    lnk "https://sync.me/search/?number=${clean_phone}"
    lnk "https://www.facebook.com/search/top/?q=${clean_phone}"
    lnk "https://www.instagram.com/accounts/password/reset/ (telefone)"
    lnk "https://www.telegram.me/${clean_phone}"

    sep
    local country_code="${clean_phone:0:3}"
    case "$country_code" in
        +55*) inf "País detectado: ${W}Brasil 🇧🇷${NC}" ;;
        +1*)  inf "País detectado: ${W}EUA/Canadá 🇺🇸${NC}" ;;
        +44*) inf "País detectado: ${W}Reino Unido 🇬🇧${NC}" ;;
        *)    inf "País: ${W}Verifique o DDI manualmente${NC}" ;;
    esac

    sep
    wrn "A verificação real requer APIs pagas (Twilio, NumVerify, etc.)"
    pause
}

# ════════════════════════════════════════════════════════════════
#  MÓDULO 5 — GEOLOCALIZADOR DE IP
# ════════════════════════════════════════════════════════════════
mod_geoip() {
    header "IP GEOLOCALIZADOR & MAPEAMENTO"
    local ip
    ip=$(get_input "Digite o IP (ou ENTER para seu IP público)")

    if [[ -z "$ip" ]]; then
        echo -e "  ${Y}[~] Detectando IP público...${NC}"
        ip=$(curl -s https://api.ipify.org 2>/dev/null)
        [[ -z "$ip" ]] && err "Não foi possível obter IP público." && pause && return
        ok "IP público detectado: ${W}${ip}${NC}"
    fi

    sep
    echo -e "  ${Y}[~] Geolocalizando ${W}${ip}${Y}...${NC}\n"

    local json
    json=$(curl -s "https://ipapi.co/${ip}/json/" 2>/dev/null)

    if echo "$json" | grep -q '"error"'; then
        err "IP inválido ou não encontrado."
        pause; return
    fi

    local country city region org lat lon timezone currency asn
    country=$(echo "$json"  | grep -o '"country_name":"[^"]*"'  | cut -d'"' -f4)
    city=$(echo "$json"     | grep -o '"city":"[^"]*"'           | cut -d'"' -f4)
    region=$(echo "$json"   | grep -o '"region":"[^"]*"'         | cut -d'"' -f4)
    org=$(echo "$json"      | grep -o '"org":"[^"]*"'            | cut -d'"' -f4)
    lat=$(echo "$json"      | grep -o '"latitude":[^,}]*'        | cut -d':' -f2)
    lon=$(echo "$json"      | grep -o '"longitude":[^,}]*'       | cut -d':' -f2)
    timezone=$(echo "$json" | grep -o '"timezone":"[^"]*"'       | cut -d'"' -f4)
    currency=$(echo "$json" | grep -o '"currency_name":"[^"]*"'  | cut -d'"' -f4)
    asn=$(echo "$json"      | grep -o '"asn":"[^"]*"'            | cut -d'"' -f4)

    ok "IP:          ${W}${ip}${NC}"
    ok "País:        ${W}${country}${NC}"
    ok "Região:      ${W}${region}${NC}"
    ok "Cidade:      ${W}${city}${NC}"
    ok "Latitude:    ${W}${lat}${NC}"
    ok "Longitude:   ${W}${lon}${NC}"
    ok "Org / ISP:   ${W}${org}${NC}"
    ok "ASN:         ${W}${asn}${NC}"
    ok "Timezone:    ${W}${timezone}${NC}"
    ok "Moeda:       ${W}${currency}${NC}"

    sep
    echo -e "\n  ${C}[i] Links complementares:${NC}\n"
    lnk "Google Maps:  https://maps.google.com/?q=${lat},${lon}"
    lnk "Shodan:       https://www.shodan.io/host/${ip}"
    lnk "VirusTotal:   https://www.virustotal.com/gui/ip-address/${ip}"
    lnk "AbuseIPDB:    https://www.abuseipdb.com/check/${ip}"
    lnk "IPVoid:       https://www.ipvoid.com/ip-blacklist-check/?ip=${ip}"

    sep
    pause
}

# ════════════════════════════════════════════════════════════════
#  MÓDULO 6 — MEU IP PÚBLICO
# ════════════════════════════════════════════════════════════════
mod_myip() {
    header "MEU IP PÚBLICO"
    echo -e "  ${Y}[~] Consultando múltiplas fontes...${NC}\n"

    local ip1 ip2 ip3
    ip1=$(curl -s https://api.ipify.org       2>/dev/null)
    ip2=$(curl -s https://ifconfig.me         2>/dev/null)
    ip3=$(curl -s https://icanhazip.com       2>/dev/null | tr -d '\n')

    ok "ipify.org:     ${W}${ip1:-N/A}${NC}"
    ok "ifconfig.me:   ${W}${ip2:-N/A}${NC}"
    ok "icanhazip.com: ${W}${ip3:-N/A}${NC}"

    sep
    local main_ip="${ip1:-$ip2}"
    if [[ -n "$main_ip" ]]; then
        echo -e "\n  ${Y}[~] Geolocalizando ${W}${main_ip}${Y}...${NC}"
        local json
        json=$(curl -s "https://ipapi.co/${main_ip}/json/" 2>/dev/null)
        local country city org
        country=$(echo "$json" | grep -o '"country_name":"[^"]*"' | cut -d'"' -f4)
        city=$(echo "$json"    | grep -o '"city":"[^"]*"'          | cut -d'"' -f4)
        org=$(echo "$json"     | grep -o '"org":"[^"]*"'           | cut -d'"' -f4)
        ok "País: ${W}${country}${NC}  Cidade: ${W}${city}${NC}"
        ok "ISP:  ${W}${org}${NC}"
    fi
    sep
    pause
}

# ════════════════════════════════════════════════════════════════
#  MÓDULO 7 — ANALISADOR DE REDES SOCIAIS
# ════════════════════════════════════════════════════════════════
mod_social() {
    header "ANALISADOR DE REDES SOCIAIS"
    local username
    username=$(get_input "Digite o username / arroba")
    username="${username//@/}"
    [[ -z "$username" ]] && err "Username vazio." && pause && return

    sep
    inf "Username alvo: ${W}@${username}${NC}"
    sep

    echo -e "\n  ${Y}[~] Verificando plataformas...${NC}\n"

    local -A platforms=(
        ["GitHub"]="https://github.com/${username}"
        ["Twitter/X"]="https://twitter.com/${username}"
        ["Instagram"]="https://instagram.com/${username}"
        ["TikTok"]="https://tiktok.com/@${username}"
        ["Reddit"]="https://reddit.com/user/${username}"
        ["LinkedIn"]="https://linkedin.com/in/${username}"
        ["Telegram"]="https://t.me/${username}"
        ["Pinterest"]="https://pinterest.com/${username}"
        ["Twitch"]="https://twitch.tv/${username}"
        ["YouTube"]="https://youtube.com/@${username}"
        ["Medium"]="https://medium.com/@${username}"
        ["Dev.to"]="https://dev.to/${username}"
        ["Gitlab"]="https://gitlab.com/${username}"
        ["Mastodon"]="https://mastodon.social/@${username}"
        ["Steam"]="https://steamcommunity.com/id/${username}"
        ["Flickr"]="https://www.flickr.com/people/${username}"
        ["Spotify"]="https://open.spotify.com/user/${username}"
        ["SoundCloud"]="https://soundcloud.com/${username}"
        ["Keybase"]="https://keybase.io/${username}"
        ["HackerNews"]="https://news.ycombinator.com/user?id=${username}"
    )

    for name in "${!platforms[@]}"; do
        local url="${platforms[$name]}"
        local code
        code=$(curl -s -o /dev/null -w "%{http_code}" -L --max-time 5 "$url" 2>/dev/null)
        if [[ "$code" == "200" ]]; then
            ok "${G}ENCONTRADO${NC}  ${W}${name}${NC}"
            echo -e "            ${D}${url}${NC}"
        else
            echo -e "  ${D}[–] ${name} (${code})${NC}"
        fi
        sleep 0.1
    done

    sep
    lnk "https://whatsmyname.app/?q=${username}"
    lnk "https://www.google.com/search?q=%22${username}%22"
    sep
    pause
}

# ════════════════════════════════════════════════════════════════
#  MÓDULO 8 — BUSCA DE USERNAME (simples, sem HTTP check)
# ════════════════════════════════════════════════════════════════
mod_username_simple() {
    header "BUSCA SIMPLES DE USERNAME"
    local username
    username=$(get_input "Digite o username")
    username="${username//@/}"
    [[ -z "$username" ]] && err "Username vazio." && pause && return

    sep
    inf "Username: ${W}@${username}${NC}"
    sep

    echo -e "\n  ${Y}Links gerados (sem verificação HTTP):${NC}\n"
    local sites=(
        "GitHub:https://github.com/${username}"
        "Twitter:https://twitter.com/${username}"
        "Instagram:https://instagram.com/${username}"
        "TikTok:https://tiktok.com/@${username}"
        "Reddit:https://reddit.com/user/${username}"
        "LinkedIn:https://linkedin.com/in/${username}"
        "Telegram:https://t.me/${username}"
        "Twitch:https://twitch.tv/${username}"
        "YouTube:https://youtube.com/@${username}"
        "Pinterest:https://pinterest.com/${username}"
        "Medium:https://medium.com/@${username}"
        "GitLab:https://gitlab.com/${username}"
        "Steam:https://steamcommunity.com/id/${username}"
        "Keybase:https://keybase.io/${username}"
        "Pastebin:https://pastebin.com/u/${username}"
    )
    for s in "${sites[@]}"; do
        local name="${s%%:*}"
        local url="${s#*:}"
        printf "  ${G}%-15s${NC} ${C}%s${NC}\n" "${name}" "${url}"
    done

    sep
    pause
}

# ════════════════════════════════════════════════════════════════
#  MÓDULO 9 — WEB INTELLIGENCE (DOMÍNIO/SITE)
# ════════════════════════════════════════════════════════════════
mod_webinfo() {
    header "WEB INTELLIGENCE — DOMÍNIO"
    local domain
    domain=$(get_input "Digite o domínio (ex: exemplo.com)")
    domain="${domain//http:\/\//}"
    domain="${domain//https:\/\//}"
    domain="${domain%%/*}"
    [[ -z "$domain" || ! "$domain" =~ \. ]] && err "Domínio inválido." && pause && return

    sep
    inf "Alvo: ${W}${domain}${NC}"
    sep

    # Resolução de IP
    echo -e "\n  ${Y}[~] Resolvendo IP...${NC}"
    local ip
    ip=$(dig +short A "$domain" 2>/dev/null | head -1)
    if [[ -n "$ip" ]]; then
        ok "IP resolvido: ${W}${ip}${NC}"
        local geo
        geo=$(curl -s "https://ipapi.co/${ip}/json/" 2>/dev/null)
        local country org
        country=$(echo "$geo" | grep -o '"country_name":"[^"]*"' | cut -d'"' -f4)
        org=$(echo "$geo"     | grep -o '"org":"[^"]*"'           | cut -d'"' -f4)
        ok "País: ${W}${country}${NC}  ISP: ${W}${org}${NC}"
    else
        wrn "Não foi possível resolver IP."
    fi

    # DNS Records
    echo -e "\n  ${Y}[~] Registros DNS:${NC}"
    local ns mx txt
    ns=$(dig +short NS "$domain" 2>/dev/null | head -4)
    mx=$(dig +short MX "$domain" 2>/dev/null | head -4)
    txt=$(dig +short TXT "$domain" 2>/dev/null | head -4)

    [[ -n "$ns"  ]] && ok "NS:  ${D}${ns//$'\n'/, }${NC}"
    [[ -n "$mx"  ]] && ok "MX:  ${D}${mx//$'\n'/, }${NC}"
    [[ -n "$txt" ]] && ok "TXT: ${D}${txt:0:80}...${NC}"

    # WHOIS resumido
    echo -e "\n  ${Y}[~] WHOIS resumido:${NC}"
    if command -v whois &>/dev/null; then
        local registrar creation expiry
        local whois_data
        whois_data=$(whois "$domain" 2>/dev/null | head -60)
        registrar=$(echo "$whois_data" | grep -i "Registrar:" | head -1 | cut -d: -f2- | xargs)
        creation=$(echo "$whois_data"  | grep -i "Creation\|Created"   | head -1 | cut -d: -f2- | xargs)
        expiry=$(echo "$whois_data"    | grep -i "Expir\|Expiry\|Expiration" | head -1 | cut -d: -f2- | xargs)
        [[ -n "$registrar" ]] && ok "Registrar: ${W}${registrar}${NC}"
        [[ -n "$creation"  ]] && ok "Criado em: ${W}${creation}${NC}"
        [[ -n "$expiry"    ]] && ok "Expira em: ${W}${expiry}${NC}"
    else
        wrn "whois não instalado."
    fi

    sep
    echo -e "\n  ${C}[i] Ferramentas externas:${NC}\n"
    lnk "Whois:        https://who.is/whois/${domain}"
    lnk "SSL/crt.sh:   https://crt.sh/?q=${domain}"
    lnk "Wayback:      https://web.archive.org/web/*/${domain}"
    lnk "Shodan:       https://www.shodan.io/search?query=hostname:${domain}"
    lnk "BuiltWith:    https://builtwith.com/${domain}"
    lnk "SecurityHdrs: https://securityheaders.com/?q=${domain}"
    lnk "VirusTotal:   https://www.virustotal.com/gui/domain/${domain}"
    lnk "DNSDumpster:  https://dnsdumpster.com"

    sep
    pause
}

# ════════════════════════════════════════════════════════════════
#  MÓDULO 10 — ENUMERAÇÃO DE SUBDOMÍNIOS
# ════════════════════════════════════════════════════════════════
mod_subdomain() {
    header "ENUMERAÇÃO DE SUBDOMÍNIOS"
    local domain
    domain=$(get_input "Digite o domínio base")
    domain="${domain//http:\/\//}"
    domain="${domain//https:\/\//}"
    domain="${domain%%/*}"
    [[ -z "$domain" || ! "$domain" =~ \. ]] && err "Domínio inválido." && pause && return

    sep
    inf "Domínio: ${W}${domain}${NC}"
    sep

    local subs=("www" "mail" "webmail" "smtp" "ftp" "sftp" "ssh" "vpn" "remote"
                "admin" "portal" "dashboard" "cpanel" "whm" "plesk"
                "api" "api2" "rest" "graphql" "ws"
                "dev" "staging" "stage" "beta" "test" "qa" "uat"
                "blog" "news" "shop" "store" "loja" "pay" "pagamento"
                "cdn" "static" "assets" "media" "img" "images"
                "app" "apps" "mobile" "m"
                "ns1" "ns2" "dns1" "dns2"
                "git" "gitlab" "jira" "confluence" "jenkins"
                "monitor" "status" "health" "uptime"
                "backup" "old" "legacy" "archive")

    echo -e "\n  ${Y}[~] Verificando ${#subs[@]} subdomínios via DNS...${NC}\n"

    local found=0
    for sub in "${subs[@]}"; do
        local fqdn="${sub}.${domain}"
        local res
        res=$(dig +short A "$fqdn" 2>/dev/null | head -1)
        if [[ -n "$res" ]]; then
            ok "${W}${fqdn}${NC}  →  ${G}${res}${NC}"
            ((found++))
        fi
    done

    sep
    if [[ $found -eq 0 ]]; then
        wrn "Nenhum subdomínio resolvido (pode estar protegido por wildcard)."
    else
        ok "Total encontrado: ${W}${found}${NC} subdomínios"
    fi

    sep
    echo -e "\n  ${C}[i] Fontes passivas para enumeração:${NC}\n"
    lnk "crt.sh:     https://crt.sh/?q=%.${domain}"
    lnk "VirusTotal: https://www.virustotal.com/gui/domain/${domain}/relations"
    lnk "Shodan:     https://www.shodan.io/search?query=hostname:${domain}"
    lnk "DNSDump:    https://dnsdumpster.com"
    lnk "Amass:      https://github.com/owasp-amass/amass"

    sep
    pause
}

# ════════════════════════════════════════════════════════════════
#  MÓDULO 11 — GOOGLE DORKING
# ════════════════════════════════════════════════════════════════
mod_dork() {
    header "GOOGLE DORKING"
    local target
    target=$(get_input "Digite o domínio ou termo alvo")
    [[ -z "$target" ]] && err "Entrada vazia." && pause && return

    sep
    inf "Alvo: ${W}${target}${NC}"
    wrn "Use apenas em sistemas que você tem AUTORIZAÇÃO para testar!"
    sep

    local -A dorks=(
        ["Arquivos PDF/XLS/DOC expostos"]="site:${target} ext:pdf OR ext:xls OR ext:xlsx OR ext:doc OR ext:docx"
        ["Painel de administração"]="site:${target} inurl:admin OR inurl:login OR inurl:dashboard OR inurl:wp-admin"
        ["Arquivos de configuração"]="site:${target} ext:env OR ext:cfg OR ext:conf OR ext:ini OR ext:xml"
        ["Diretórios abertos"]="site:${target} intitle:\"index of\""
        ["Erros de banco de dados"]="site:${target} \"sql syntax\" OR \"mysql error\" OR \"ORA-\" OR \"PostgreSQL\""
        ["Emails expostos"]="site:${target} \"@${target}\""
        ["Backups expostos"]="site:${target} ext:bak OR ext:backup OR ext:old OR ext:~"
        ["APIs e endpoints"]="site:${target} inurl:api OR inurl:swagger OR inurl:graphql OR inurl:v1 OR inurl:v2"
        ["Credenciais em código"]="site:${target} \"password\" OR \"passwd\" OR \"api_key\" OR \"secret\""
        ["Câmeras e IoT"]="site:${target} intitle:\"webcam\" OR inurl:\"view/index.shtml\""
        ["Subdomínios via Google"]="site:*.${target}"
        ["Informações de versão"]="site:${target} \"powered by\" OR \"version\" inurl:readme"
    )

    echo -e "\n  ${Y}[~] Dorks gerados para ${W}${target}${Y}:${NC}\n"
    for desc in "${!dorks[@]}"; do
        local dork="${dorks[$desc]}"
        local encoded
        encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${dork}'))" 2>/dev/null \
                  || echo "${dork// /+}")
        echo -e "  ${M}◆ ${W}${desc}${NC}"
        echo -e "    ${D}${dork}${NC}"
        echo -e "    ${B}→ https://www.google.com/search?q=${encoded}${NC}"
        echo ""
    done

    sep
    lnk "Google Hacking DB: https://www.exploit-db.com/google-hacking-database"
    lnk "DorkSearch:        https://dorksearch.com"
    sep
    pause
}

# ════════════════════════════════════════════════════════════════
#  MÓDULO 12 — INFORMAÇÕES DO SISTEMA
# ════════════════════════════════════════════════════════════════
mod_sysinfo() {
    header "INFORMAÇÕES DO SISTEMA"
    sep

    ok "Hostname:    ${W}$(hostname)${NC}"
    ok "Usuário:     ${W}$(whoami)${NC}"
    ok "Shell:       ${W}${SHELL}${NC}"
    ok "OS:          ${W}$(uname -s) $(uname -r)${NC}"
    ok "Arquitetura: ${W}$(uname -m)${NC}"
    ok "Data/Hora:   ${W}$(date)${NC}"
    ok "Uptime:      ${W}$(uptime -p 2>/dev/null || uptime)${NC}"

    sep
    echo -e "\n  ${Y}[~] Interfaces de rede:${NC}\n"
    if command -v ip &>/dev/null; then
        ip -br addr 2>/dev/null | while read -r iface state addr; do
            [[ "$state" == "UP" ]] && ok "${W}${iface}${NC}  ${G}${addr}${NC}" \
                                     || inf "${D}${iface}  ${addr}${NC}"
        done
    elif command -v ifconfig &>/dev/null; then
        ifconfig | grep -E "^[a-z]|inet " | while read -r line; do
            echo -e "  ${D}${line}${NC}"
        done
    fi

    sep
    echo -e "\n  ${Y}[~] DNS configurado:${NC}"
    cat /etc/resolv.conf 2>/dev/null | grep "^nameserver" | while read -r line; do
        ok "${D}${line}${NC}"
    done

    sep
    echo -e "\n  ${Y}[~] Processos de rede ativos (top 10):${NC}"
    if command -v ss &>/dev/null; then
        ss -tulpn 2>/dev/null | head -12 | while read -r line; do
            echo -e "  ${D}${line}${NC}"
        done
    fi

    sep
    pause
}

# ════════════════════════════════════════════════════════════════
#  MÓDULO 13 — SOBRE / CRÉDITOS
# ════════════════════════════════════════════════════════════════
mod_about() {
    clear
    echo -e "${R}"
    cat << 'EOF'
  ██████╗  █████╗ ██████╗ ██╗      ██████╗      ██████╗██╗   ██╗██████╗ ███████╗██████╗
  ██╔══██╗██╔══██╗██╔══██╗██║     ██╔═══██╗    ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗
  ██████╔╝███████║██████╔╝██║     ██║   ██║    ██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝
  ██╔═══╝ ██╔══██║██╔══██╗██║     ██║   ██║    ██║       ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗
  ██║     ██║  ██║██████╔╝███████╗╚██████╔╝    ╚██████╗   ██║   ██████╔╝███████╗██║  ██║
  ╚═╝     ╚═╝  ╚═╝╚═════╝ ╚══════╝ ╚═════╝      ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝
EOF
    echo -e "${NC}"
    sep
    echo -e "  ${W}Ferramenta:${NC}  Pablo Cyber OSINT Toolkit v1.0"
    echo -e "  ${W}Autor:${NC}       Pablo Cyber"
    echo -e "  ${W}Tipo:${NC}        Reconhecimento passivo / OSINT"
    echo -e "  ${W}Linguagem:${NC}   Bash Shell (Linux)"
    sep
    echo -e "\n  ${Y}Módulos disponíveis:${NC}"
    echo -e "  ${G}01${NC} Email → Contas registradas"
    echo -e "  ${G}02${NC} Gravatar por email"
    echo -e "  ${G}03${NC} Enumerar emails do domínio"
    echo -e "  ${G}04${NC} OSINT por número de telefone"
    echo -e "  ${G}05${NC} IP Geolocalizador & Mapeamento"
    echo -e "  ${G}06${NC} Meu IP público"
    echo -e "  ${G}07${NC} Analisador de redes sociais (com HTTP check)"
    echo -e "  ${G}08${NC} Busca simples de username"
    echo -e "  ${G}09${NC} Web Intelligence / Domínio"
    echo -e "  ${G}10${NC} Enumeração de subdomínios"
    echo -e "  ${G}11${NC} Google Dorking"
    echo -e "  ${G}12${NC} Informações do sistema"
    sep
    echo -e "\n  ${R}AVISO LEGAL:${NC}"
    echo -e "  ${D}Esta ferramenta é exclusivamente para uso educacional e em"
    echo -e "  sistemas com autorização explícita. Uso indevido é crime.${NC}"
    sep
    pause
}

# ════════════════════════════════════════════════════════════════
#  MENU PRINCIPAL
# ════════════════════════════════════════════════════════════════
menu() {
    while true; do
        banner
        check_deps

        echo -e "  ${D}══════════════ EMAIL & IDENTIDADE ══════════════${NC}"
        echo -e "  ${G}[01]${NC} Email → Contas Registradas"
        echo -e "  ${G}[02]${NC} Gravatar por Email"
        echo -e "  ${G}[03]${NC} Enumerar Emails do Domínio"
        echo ""
        echo -e "  ${D}══════════════ TELEFONE ═════════════════════════${NC}"
        echo -e "  ${G}[04]${NC} OSINT por Número de Telefone"
        echo ""
        echo -e "  ${D}══════════════ IP & GEOLOCALIZAÇÃO ══════════════${NC}"
        echo -e "  ${G}[05]${NC} 🌍 IP Geolocalizador & Mapeamento"
        echo -e "  ${G}[06]${NC} Meu IP Público"
        echo ""
        echo -e "  ${D}══════════════ REDES SOCIAIS & USUÁRIO ══════════${NC}"
        echo -e "  ${G}[07]${NC} Social Media Analyzer (com verificação HTTP)"
        echo -e "  ${G}[08]${NC} Busca Simples de Username"
        echo ""
        echo -e "  ${D}══════════════ WEB INTELLIGENCE ═════════════════${NC}"
        echo -e "  ${G}[09]${NC} Web Info / Domínio (WHOIS, DNS, IP)"
        echo -e "  ${G}[10]${NC} Enumeração de Subdomínios"
        echo -e "  ${G}[11]${NC} Google Dorking"
        echo ""
        echo -e "  ${D}══════════════ SISTEMA ══════════════════════════${NC}"
        echo -e "  ${G}[12]${NC} Informações do Sistema"
        echo ""
        echo -e "  ${D}══════════════ OUTROS ═══════════════════════════${NC}"
        echo -e "  ${C}[00]${NC} Sobre / Créditos"
        echo -e "  ${R}[99]${NC} Sair"
        echo ""
        sep

        local choice
        choice=$(get_input "Escolha uma opção")

        case "$choice" in
            1|01)  mod_email_accounts ;;
            2|02)  mod_gravatar ;;
            3|03)  mod_email_enum ;;
            4|04)  mod_phone ;;
            5|05)  mod_geoip ;;
            6|06)  mod_myip ;;
            7|07)  mod_social ;;
            8|08)  mod_username_simple ;;
            9|09)  mod_webinfo ;;
            10)    mod_subdomain ;;
            11)    mod_dork ;;
            12)    mod_sysinfo ;;
            0|00)  mod_about ;;
            99)
                clear
                banner
                echo -e "  ${Y}Até logo! — Pablo Cyber${NC}\n"
                exit 0
                ;;
            *)
                wrn "Opção inválida: ${choice}"
                sleep 1
                ;;
        esac
    done
}

# ── Entry point ──────────────────────────────────────────────────
menu
