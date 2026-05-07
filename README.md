# 🔍 Pablo Cyber — OSINT Toolkit

```
██████╗  █████╗ ██████╗ ██╗      ██████╗      ██████╗██╗   ██╗██████╗ ███████╗██████╗
██╔══██╗██╔══██╗██╔══██╗██║     ██╔═══██╗    ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗
██████╔╝███████║██████╔╝██║     ██║   ██║    ██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝
██╔═══╝ ██╔══██║██╔══██╗██║     ██║   ██║    ██║       ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗
██║     ██║  ██║██████╔╝███████╗╚██████╔╝    ╚██████╗   ██║   ██████╔╝███████╗██║  ██║
╚═╝     ╚═╝  ╚═╝╚═════╝ ╚══════╝ ╚═════╝      ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝
```

> **Ferramenta de reconhecimento passivo e inteligência de código aberto (OSINT)**  
> Desenvolvida em Bash Shell para Linux — by **Pablo Cyber**

---

## 📋 Índice

- [Sobre](#sobre)
- [Recursos](#recursos)
- [Requisitos](#requisitos)
- [Instalação](#instalação)
- [Como Usar](#como-usar)
- [Módulos](#módulos)
- [Exemplos de Uso](#exemplos-de-uso)
- [Aviso Legal](#aviso-legal)

---

## Sobre

**Pablo Cyber OSINT Toolkit** é uma ferramenta de linha de comando desenvolvida em Bash Shell para Linux, com foco em reconhecimento passivo e coleta de inteligência de fontes abertas (OSINT). Todas as técnicas utilizadas baseiam-se em APIs públicas, consultas DNS e links para serviços externos — sem qualquer acesso não autorizado a sistemas.

- **Linguagem:** Bash Shell
- **Plataforma:** Linux (Debian, Ubuntu, Kali, Parrot OS, Arch, etc.)
- **Versão:** 1.0
- **Autor:** Pablo Cyber
- **Linhas de código:** ~800

---

## Recursos

| Categoria | Funcionalidades |
|-----------|----------------|
| 📧 Email & Identidade | Verificação de contas, Gravatar, enumeração de emails |
| 📱 Telefone | OSINT por número, links para rastreamento passivo |
| 🌍 IP & Geolocalização | Geoloc via API, detecção de IP público, links Shodan/AbuseIPDB |
| 👤 Redes Sociais | Verificação HTTP em 20+ plataformas, busca de username |
| 🌐 Web Intelligence | WHOIS, DNS, subdomínios, SSL/crt.sh, Wayback Machine |
| 🔎 Google Dorking | 12 dorks pré-configurados com URL encoding automático |
| 💻 Sistema | Interfaces de rede, DNS local, portas abertas |

---

## Requisitos

### Sistema Operacional
- Linux (testado em Ubuntu 22.04, Kali Linux, Parrot OS)
- Bash 4.0 ou superior

### Dependências

| Ferramenta | Uso | Obrigatório |
|------------|-----|-------------|
| `curl` | Requisições HTTP e APIs | ✅ Sim |
| `dig` | Consultas DNS | ✅ Sim |
| `whois` | Informações de domínio | ✅ Sim |
| `nmap` | Mapeamento de rede | ⚠️ Recomendado |
| `jq` | Parse de JSON | ⚠️ Recomendado |
| `nslookup` | Resolução de nomes | ⚠️ Recomendado |
| `host` | Resolução de nomes | ⚠️ Recomendado |
| `python3` | Encoding de URLs (dorks) | ⚠️ Recomendado |

---

## Instalação

### 1. Clone ou baixe o script

```bash
# Via git
git clone https://github.com/pablocyber/osint-toolkit.git
cd osint-toolkit

# Ou baixe diretamente
wget https://raw.githubusercontent.com/pablocyber/osint-toolkit/main/pablo_cyber.sh
```

### 2. Instale as dependências

**Debian / Ubuntu / Kali / Parrot OS:**
```bash
sudo apt update
sudo apt install curl dnsutils whois nmap jq python3 -y
```

**Arch Linux / BlackArch:**
```bash
sudo pacman -S curl bind whois nmap jq python
```

**Fedora / RHEL:**
```bash
sudo dnf install curl bind-utils whois nmap jq python3 -y
```

### 3. Dê permissão de execução

```bash
chmod +x pablo_cyber.sh
```

### 4. Execute

```bash
./pablo_cyber.sh
```

---

## Como Usar

Ao iniciar, o menu principal será exibido com todas as opções disponíveis. Navegue digitando o número do módulo desejado e pressione `ENTER`.

```
  ══════════════ EMAIL & IDENTIDADE ══════════════
  [01] Email → Contas Registradas
  [02] Gravatar por Email
  [03] Enumerar Emails do Domínio

  ══════════════ TELEFONE ═════════════════════════
  [04] OSINT por Número de Telefone

  ══════════════ IP & GEOLOCALIZAÇÃO ══════════════
  [05] 🌍 IP Geolocalizador & Mapeamento
  [06] Meu IP Público

  ══════════════ REDES SOCIAIS & USUÁRIO ══════════
  [07] Social Media Analyzer (com verificação HTTP)
  [08] Busca Simples de Username

  ══════════════ WEB INTELLIGENCE ═════════════════
  [09] Web Info / Domínio (WHOIS, DNS, IP)
  [10] Enumeração de Subdomínios
  [11] Google Dorking

  ══════════════ SISTEMA ══════════════════════════
  [12] Informações do Sistema

  [00] Sobre / Créditos
  [99] Sair
```

---

## Módulos

### [01] Email → Contas Registradas
Dado um endereço de email, gera links diretos para verificação em múltiplos serviços e consulta registros MX do domínio via `dig`.

**Serviços verificados:**
- HaveIBeenPwned, Gravatar, GitHub, LinkedIn, Google, Twitter/X, Pastebin, Skype

**Exemplo:**
```
► Digite o email: alvo@exemplo.com

  [✔] HaveIBeenPwned  → https://haveibeenpwned.com/account/alvo@exemplo.com
  [✔] GitHub Search   → https://github.com/search?q=alvo@exemplo.com&type=users
  [✔] Registros MX encontrados:
       10 mail.exemplo.com.
```

---

### [02] Gravatar por Email
Calcula o hash MD5 real do email e consulta a API do Gravatar para verificar se existe uma conta associada.

**Retorna:** Hash MD5, URL do perfil, URL do avatar, dados JSON (nome, URL pública)

---

### [03] Enumerar Emails do Domínio
Gera padrões comuns de emails corporativos para um domínio e consulta registros SPF/DMARC via DNS.

**Prefixos gerados:** `admin`, `contato`, `suporte`, `rh`, `financeiro`, `ti`, `ceo`, `cto` e +20 outros

**Fontes externas:** Hunter.io, Phonebook.cz, IntelX, EmailRep

---

### [04] OSINT por Número de Telefone
Gera links de verificação passiva para um número de telefone e tenta detectar o país pelo DDI.

**Serviços:** Truecaller, Sync.me, Facebook, Telegram, Google, WhocalledMe

---

### [05] IP Geolocalizador & Mapeamento
Consulta a API pública `ipapi.co` e retorna informações detalhadas do IP.

**Retorna:**
- País, região, cidade, coordenadas (lat/lon)
- ISP, ASN, timezone, moeda
- Links para Google Maps, Shodan, VirusTotal, AbuseIPDB, IPVoid

---

### [06] Meu IP Público
Consulta três fontes simultâneas (`ipify.org`, `ifconfig.me`, `icanhazip.com`) e realiza geolocalização automática do IP detectado.

---

### [07] Social Media Analyzer
Verifica a existência de um username em **20 plataformas** realizando requisições HTTP reais com `curl` e analisando o código de resposta.

**Plataformas verificadas:**
GitHub, Twitter/X, Instagram, TikTok, Reddit, LinkedIn, Telegram, Pinterest, Twitch, YouTube, Medium, Dev.to, GitLab, Mastodon, Steam, Flickr, Spotify, SoundCloud, Keybase, HackerNews

---

### [08] Busca Simples de Username
Gera links diretos para 15 plataformas sem verificação HTTP — mais rápido, ideal para consulta manual rápida.

---

### [09] Web Intelligence — Domínio
Coleta informações completas sobre um domínio:

- Resolução de IP + geolocalização
- Registros DNS: NS, MX, TXT
- WHOIS resumido (registrar, data de criação, expiração)
- Links para: Whois, crt.sh, Wayback Machine, Shodan, BuiltWith, SecurityHeaders, VirusTotal

---

### [10] Enumeração de Subdomínios
Testa ~50 prefixos comuns via `dig` e exibe os subdomínios que resolvem com sucesso.

**Prefixos testados:** `www`, `mail`, `api`, `dev`, `staging`, `admin`, `vpn`, `git`, `jenkins`, `cdn`, `backup` e outros

**Fontes passivas:** crt.sh, VirusTotal, Shodan, DNSDumpster, OWASP Amass

---

### [11] Google Dorking
Gera automaticamente 12 dorks configurados para o alvo, com URL encoding para abertura direta no navegador.

**Dorks incluídos:**
| Dork | Objetivo |
|------|----------|
| `site:alvo ext:pdf OR ext:xls` | Arquivos expostos |
| `site:alvo inurl:admin OR inurl:login` | Painéis administrativos |
| `site:alvo ext:env OR ext:cfg` | Arquivos de configuração |
| `site:alvo intitle:"index of"` | Diretórios abertos |
| `site:alvo "sql syntax" OR "mysql error"` | Erros de banco de dados |
| `site:alvo "password" OR "api_key"` | Credenciais em código |
| `site:alvo ext:bak OR ext:backup` | Arquivos de backup |
| `site:alvo inurl:api OR inurl:swagger` | APIs e endpoints |
| `site:*.alvo` | Subdomínios via Google |

> ⚠️ **Use apenas em sistemas com autorização explícita.**

---

### [12] Informações do Sistema
Exibe informações do ambiente local: hostname, usuário, OS, arquitetura, interfaces de rede ativas, servidores DNS configurados e portas abertas via `ss`.

---

## Exemplos de Uso

### Investigar um domínio suspeito
```bash
./pablo_cyber.sh
# Selecione [09] → Digite: dominio.com
```

### Verificar se um email vazou
```bash
./pablo_cyber.sh
# Selecione [01] → Digite: usuario@email.com
```

### Rastrear origem de um IP
```bash
./pablo_cyber.sh
# Selecione [05] → Digite: 203.0.113.42
```

### Buscar presença de um username
```bash
./pablo_cyber.sh
# Selecione [07] → Digite: nomeusuario
```

### Gerar dorks para um site
```bash
./pablo_cyber.sh
# Selecione [11] → Digite: site-alvo.com
```

---

## APIs Públicas Utilizadas

| API | Endpoint | Uso |
|-----|----------|-----|
| ipapi.co | `https://ipapi.co/{ip}/json/` | Geolocalização de IP |
| ipify.org | `https://api.ipify.org` | Detecção de IP público |
| ifconfig.me | `https://ifconfig.me` | Detecção de IP público |
| icanhazip.com | `https://icanhazip.com` | Detecção de IP público |
| Gravatar | `https://en.gravatar.com/{hash}.json` | Perfil Gravatar |

---

## Estrutura do Projeto

```
pablo_cyber/
├── pablo_cyber.sh      # Script principal (~800 linhas)
└── README.md           # Documentação
```

---

## Aviso Legal

> ⚠️ **IMPORTANTE — LEIA ANTES DE USAR**

Esta ferramenta foi desenvolvida **exclusivamente para fins educacionais**, pesquisa em segurança e testes em sistemas nos quais o usuário possui **autorização explícita e documentada**.

- Não utilize esta ferramenta em sistemas, redes ou pessoas sem permissão.
- O uso indevido pode configurar crimes previstos na **Lei nº 12.737/2012 (Lei Carolina Dieckmann)** e no **Marco Civil da Internet (Lei nº 12.965/2014)** no Brasil, além de legislações equivalentes em outros países.
- O autor não se responsabiliza por danos causados pelo uso inadequado desta ferramenta.
- Todas as funcionalidades utilizam apenas **técnicas passivas** e **APIs públicas** — nenhum exploit ou acesso não autorizado é realizado.

**Use com responsabilidade. Hacking ético começa com autorização.**

---

## Licença

Este projeto é distribuído para fins educacionais.  
Redistribuição permitida com créditos ao autor original.

---

<div align="center">

**Desenvolvido por Pablo Cyber**  
*OSINT | Segurança Ofensiva | Reconhecimento Passivo*

</div>
