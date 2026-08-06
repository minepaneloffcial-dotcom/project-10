#!/bin/bash

# ====================================================
#   TASIN — PTERODACTYL CONTROL CENTER v3.0
#   Clean • Smooth • Static UI
#   Coded by tasin
# ====================================================

# --- COLOR PALETTE ---
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_BLACK='\033[0;30m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'
C_MAGENTA='\033[0;35m'
C_CYAN='\033[0;36m'
C_WHITE='\033[0;37m'
C_GRAY='\033[0;90m'
C_BRRED='\033[1;31m'
C_BRGREEN='\033[1;32m'
C_BRYELLOW='\033[1;33m'
C_BRCYAN='\033[1;36m'
C_BRWHITE='\033[1;37m'

# --- ACCENT COLORS ---
C_ACCENT='\033[38;5;147m'
C_ACCENT2='\033[38;5;111m'
C_HIGHLIGHT='\033[38;5;228m'
C_SUCCESS='\033[38;5;82m'
C_WARN='\033[38;5;214m'
C_ERROR='\033[38;5;203m'
C_MENU_NUM='\033[38;5;180m'
C_BORDER='\033[38;5;240m'
C_TITLE='\033[38;5;189m'

# --- BOX DRAWING ---
T_L='┌'
T_R='┐'
B_L='└'
B_R='┘'
H='─'
V='│'
X_L='├'
X_R='┤'

# --- SYMBOLS ---
S_OK="${C_SUCCESS}●${C_RESET}"
S_ERR="${C_ERROR}●${C_RESET}"
S_INFO="${C_ACCENT}◆${C_RESET}"
S_WAIT="${C_WARN}◉${C_RESET}"
S_DOT="${C_BORDER}·${C_RESET}"

# --- STATUS CACHE ---
PANEL_INSTALLED=false
WINGS_INSTALLED=false

check_install_status() {
    [ -d "/var/www/pterodactyl" ] && PANEL_INSTALLED=true || PANEL_INSTALLED=false
    [ -f "/etc/pterodactyl/wings" ] && WINGS_INSTALLED=true || WINGS_INSTALLED=false
}

# ═══════════════════════════════════════════════════════
#                   UI HELPERS
# ═══════════════════════════════════════════════════════

status() {
    local icon msg
    case "$1" in
        ok)   icon="${S_OK}"   ;;
        err)  icon="${S_ERR}"  ;;
        info) icon="${S_INFO}" ;;
        wait) icon="${S_WAIT}" ;;
        *)    icon="${S_DOT}"  ;;
    esac
    printf "  ${icon}  ${C_WHITE}$2${C_RESET}\n"
}

pause() {
    printf "\n"
    read -p "  ${C_DIM}Press [Enter] to go menu...${C_RESET}"
}

ask_confirm() {
    local msg="$1" default="${2:-y}"
    local hint="Y/n"
    [ "$default" = "n" ] && hint="y/N"
    printf "  ${C_ACCENT}▸${C_RESET} ${C_WHITE}${msg}${C_RESET} ${C_DIM}(${hint})${C_RESET} "
    local ans
    read -n 1 -s ans
    echo ""
    [[ "$default" == "y" ]] && [[ ! "$ans" =~ [Nn] ]] && return 0
    [[ "$default" == "n" ]] && [[ "$ans" =~ [Yy] ]] && return 0
    return 1
}

ask_timeout() {
    local label="$1" default="$2" var_name="$3" timeout="${4:-8}"
    printf "  ${C_ACCENT}▸${C_RESET} ${C_WHITE}${label}${C_RESET} ${C_DIM}[${default}]${C_RESET} "
    printf "${C_DIM}→${C_RESET} "
    local input
    if ! read -t "$timeout" input; then
        printf "\n  ${C_WARN}⟳${C_RESET} ${C_DIM}Timeout — using default${C_RESET}\n"
        eval "${var_name}='${default}'"
        return
    fi
    [ -z "$input" ] && input="$default"
    eval "${var_name}='${input}'"
}

ask_custom() {
    local label="$1" default="$2" var_name="$3"
    printf "  ${C_WHITE}•${C_RESET} ${C_WHITE}${label}${C_RESET} ${C_DIM}[${default}]${C_RESET}\n"
    printf "  ${C_DIM}╰─>${C_RESET} "
    local input
    read input
    if [ -z "$input" ] && [ -n "$default" ]; then
        eval "${var_name}='${default}'"
    else
        eval "${var_name}='${input}'"
    fi
}

# ═══════════════════════════════════════════════════════
#                   HEADER
# ═══════════════════════════════════════════════════════

show_header() {
    local module="$1"
    clear
    printf "${C_ACCENT2}──╮${C_RESET}\n"
    printf "${C_ACCENT2}  │${C_RESET}  ${C_TITLE}${C_BOLD}TASIN — CONTROL CENTER${C_RESET}  ${C_ACCENT2}╭──${C_RESET}\n"
    printf "${C_ACCENT2}  ╰${C_BORDER}──${C_ACCENT2}──${C_BORDER}──${C_ACCENT2}──${C_BORDER}──${C_ACCENT2}──${C_BORDER}──${C_ACCENT2}──${C_BORDER}──${C_ACCENT2}──${C_BORDER}──${C_ACCENT2}──${C_BORDER}──${C_ACCENT2}──${C_BORDER}──${C_ACCENT2}──${C_BORDER}──${C_ACCENT2}──${C_BORDER}╮${C_RESET}\n"
    if [ -n "$module" ]; then
        printf "${C_BORDER}  │${C_RESET}                                               ${C_BORDER}│${C_RESET}\n"
        printf "${C_BORDER}  │${C_RESET}  ${C_ACCENT}${C_BOLD}▸ ${module}${C_RESET}                                   ${C_BORDER}│${C_RESET}\n"
        printf "${C_BORDER}  │${C_RESET}                                               ${C_BORDER}│${C_RESET}\n"
    fi
    printf "${C_ACCENT2}  ╭${C_BORDER}──${C_ACCENT2}──${C_BORDER}──${C_ACCENT2}──${C_BORDER}──${C_ACCENT2}──${C_BORDER}──${C_ACCENT2}──${C_BORDER}──${C_ACCENT2}──${C_BORDER}──${C_ACCENT2}──${C_BORDER}──${C_ACCENT2}──${C_BORDER}──${C_ACCENT2}──${C_BORDER}──${C_ACCENT2}──${C_BORDER}╯${C_RESET}\n"
    printf "${C_ACCENT2}──╯${C_RESET}\n"
    printf "\n"
}

# ═══════════════════════════════════════════════════════
#              MAIN MENU — FIXED TERMINAL
# ═══════════════════════════════════════════════════════

show_main_menu() {
    clear

    # ── ASCII LOGO ──
    printf "${C_ACCENT}               .                                      .o8                          .               oooo  ${C_RESET}\n"
    printf "${C_ACCENT}             .o8                                     \"888                        .o8               \`888  ${C_RESET}\n"
    printf "${C_ACCENT}oo.ooooo.  .o888oo  .ooooo.  oooo d8b  .ooooo.   .oooo888   .oooo.    .ooooo.  .o888oo oooo    ooo  888  ${C_RESET}\n"
    printf "${C_ACCENT} 888' \`88b   888   d88' \`88b \`888\"\"8P d88' \`88b d88' \`888  \`P  )88b  d88' \\\"Y8   888    \`88.  .8'   888  ${C_RESET}\n"
    printf "${C_ACCENT} 888   888   888   888ooo888  888     888   888 888   888   .oP\"888  888         888     \`88..8'    888  ${C_RESET}\n"
    printf "${C_ACCENT} 888   888   888 . 888    .o  888     888   888 888   888  d8(  888  888   .o8   888 .    \`888'     888  ${C_RESET}\n"
    printf "${C_ACCENT} 888bod8P'   \"888\" \`Y8bod8P' d888b    \`Y8bod8P' \`Y8bod88P\" \`Y888\"\"8o \`Y8bod8P'   \"888\"     .8'     o888o ${C_RESET}\n"
    printf "${C_ACCENT} 888                                                                                   .o..P'             ${C_RESET}\n"
    printf "${C_ACCENT}o888o                                                                                  \`Y8P'              ${C_RESET}\n"
    printf "\n"
    printf "           ${C_TITLE}${C_BOLD}PREMIUM PTERODACTYL INSTALLER${C_RESET}\n"
    printf "${C_BORDER}────────────────────────────────────────────────────────────${C_RESET}\n"
    printf "\n"

    # ── STATUS BAR ──
    printf "  ${C_BORDER}┌──────────────────────────────────────────────────────┐${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}  ${C_DIM}SYSTEM${C_RESET}                                              ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}                                                      ${C_BORDER}│${C_RESET}\n"
    if $PANEL_INSTALLED; then
        printf "  ${C_BORDER}│${C_RESET}    Panel  ${S_OK} ${C_SUCCESS}Installed${C_RESET}                                   ${C_BORDER}│${C_RESET}\n"
    else
        printf "  ${C_BORDER}│${C_RESET}    Panel  ${S_ERR} ${C_ERROR}Not Installed${C_RESET}                               ${C_BORDER}│${C_RESET}\n"
    fi
    if $WINGS_INSTALLED; then
        printf "  ${C_BORDER}│${C_RESET}    Wings  ${S_OK} ${C_SUCCESS}Installed${C_RESET}                                   ${C_BORDER}│${C_RESET}\n"
    else
        printf "  ${C_BORDER}│${C_RESET}    Wings  ${S_ERR} ${C_ERROR}Not Installed${C_RESET}                               ${C_BORDER}│${C_RESET}\n"
    fi
    printf "  ${C_BORDER}│${C_RESET}                                                      ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}└──────────────────────────────────────────────────────┘${C_RESET}\n"
    printf "\n"

    # ── MENU OPTIONS ──
    printf "  ${C_BORDER}┌──────────────────────────────────────────────────────┐${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}  ${C_BRWHITE}${C_BOLD}PANEL${C_RESET}                                                ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}                                                      ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}    ${C_MENU_NUM}${C_BOLD}01${C_RESET}  ${C_WHITE}Install Panel${C_RESET}           ${C_DIM}·  Fresh Setup${C_RESET}       ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}    ${C_MENU_NUM}${C_BOLD}02${C_RESET}  ${C_WHITE}Update Panel${C_RESET}           ${C_DIM}·  New Release${C_RESET}       ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}    ${C_MENU_NUM}${C_BOLD}03${C_RESET}  ${C_WHITE}Uninstall Panel${C_RESET}         ${C_DIM}·  Remove All${C_RESET}        ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}                                                      ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}  ${C_BRWHITE}${C_BOLD}CONFIGURATION${C_RESET}                                        ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}                                                      ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}    ${C_MENU_NUM}${C_BOLD}04${C_RESET}  ${C_WHITE}Domain & SSL${C_RESET}            ${C_DIM}·  Change Host${C_RESET}       ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}    ${C_MENU_NUM}${C_BOLD}05${C_RESET}  ${C_WHITE}Database${C_RESET}                ${C_DIM}·  phpMyAdmin${C_RESET}        ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}    ${C_MENU_NUM}${C_BOLD}06${C_RESET}  ${C_WHITE}Create User${C_RESET}             ${C_DIM}·  Admin / User${C_RESET}      ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}                                                      ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}  ${C_BRWHITE}${C_BOLD}WINGS${C_RESET}                                                ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}                                                      ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}    ${C_MENU_NUM}${C_BOLD}07${C_RESET}  ${C_WHITE}Install Wings${C_RESET}           ${C_DIM}·  Daemon Setup${C_RESET}      ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}    ${C_MENU_NUM}${C_BOLD}08${C_RESET}  ${C_WHITE}Configure Wings${C_RESET}          ${C_DIM}·  Node Config${C_RESET}       ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}                                                      ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}    ${C_GRAY} 0${C_RESET}  ${C_GRAY}Exit${C_RESET}                                               ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}                                                      ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}└──────────────────────────────────────────────────────┘${C_RESET}\n"
    printf "\n"

    # ── TERMINAL PROMPT ──
    printf "  ${C_ACCENT2}┌─${C_RESET} ${C_DIM}terminal${C_RESET} ${C_ACCENT2}───────────────────────────────────────────────────${C_RESET}\n"
    printf "  ${C_ACCENT2}│${C_RESET} ${C_GREEN}root${C_RESET}${C_DIM}@${C_RESET}${C_ACCENT}tasin${C_RESET}${C_DIM}:~#${C_RESET} "
}

# ═══════════════════════════════════════════════════════
#          GITHUB VERSION FETCHER
# ═══════════════════════════════════════════════════════

fetch_versions() {
    local repo="$1"
    curl -sf "https://api.github.com/repos/$repo/releases?per_page=20" 2>/dev/null | \
    python3 -c "
import sys, json
data = json.load(sys.stdin)
for r in data:
    if not r.get('prerelease', False):
        tag = r.get('tag_name', '')
        if tag.startswith('v'):
            print(tag)
" 2>/dev/null
}

# ═══════════════════════════════════════════════════════
#                MODULE: INSTALL PANEL
# ═══════════════════════════════════════════════════════

install_panel() {
    show_header "PANEL INSTALLATION"

    if $PANEL_INSTALLED; then
        status err "Panel is already installed"
        pause
        return
    fi

    printf "  ${C_BORDER}┌──────────────────────────────────────────────────────┐${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}  ${C_WARN}${C_BOLD}⚠  This will install Pterodactyl Panel${C_RESET}              ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}  ${C_DIM}   Make sure your domain points to this server${C_RESET}      ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}└──────────────────────────────────────────────────────┘${C_RESET}\n"
    printf "\n"

    if ! ask_confirm "Proceed with installation?"; then
        status info "Cancelled"
        pause
        return
    fi

    # --- Data Collection ---
    printf "\n"
    local rand_pass
    rand_pass=$(openssl rand -base64 16)
    
    ask_custom "Timezone" "Asia/Kolkata" p_timezone
    ask_custom "Panel Domain" "localhost" p_domain
    ask_custom "Admin Email" "admin@gmail.com" p_email
    ask_custom "Admin Username" "admin" p_user
    ask_custom "Admin Password" "$rand_pass" p_pass

    # --- Version Select ---
    printf "\n"
    status info "Fetching available versions..."
    local versions
    versions=$(fetch_versions "pterodactyl/panel")

    local selected_version="latest"
    
    if [ -n "$versions" ]; then
        printf "\n"
        printf "  ${C_BRWHITE}${C_BOLD}:: Available Panel Versions${C_RESET}\n"
        local i=1
        while IFS= read -r tag; do
            [ -z "$tag" ] && continue
            printf "  ${C_DIM}%2d.${C_RESET} ${C_WHITE}%s${C_RESET}\n" "$i" "$tag"
            ((i++))
        done <<< "$versions"
        
        local max=$((i-1))
        printf "\n"
        ask_custom "Select version [1-${max}]" "1" p_ver_choice
        
        if [[ "$p_ver_choice" =~ ^[0-9]+$ ]] && [ "$p_ver_choice" -ge 1 ] && [ "$p_ver_choice" -le "$max" ]; then
            selected_version=$(echo "$versions" | sed -n "${p_ver_choice}p")
        else
            selected_version=$(echo "$versions" | head -n1)
        fi
    else
        printf "\n"
        status info "Could not fetch versions. Defaulting to latest."
    fi

    # --- Review Box ---
    printf "\n"
    printf "  ${C_WARN}┌─[ REVIEW CONFIGURATION ]${C_RESET}\n"
    printf "  ${C_WARN}│${C_RESET} ${C_DIM}Domain:${C_RESET}   ${C_WHITE}${p_domain}${C_RESET}\n"
    printf "  ${C_WARN}│${C_RESET} ${C_DIM}Email:${C_RESET}    ${C_WHITE}${p_email}${C_RESET}\n"
    printf "  ${C_WARN}│${C_RESET} ${C_DIM}User:${C_RESET}     ${C_WHITE}${p_user}${C_RESET}\n"
    printf "  ${C_WARN}│${C_RESET} ${C_DIM}Version:${C_RESET}  ${C_SUCCESS}${selected_version}${C_RESET}\n"
    printf "  ${C_WARN}└───────────────────────────${C_RESET}\n"
    printf "\n"
    
    printf "  ${C_WHITE}Start Installation? (y/n):${C_RESET} "
    local start_install
    read -n 1 -s start_install
    echo ""
    
    if [[ ! "$start_install" =~ [Yy] ]]; then
        status info "Installation aborted"
        pause
        return
    fi

    # --- Prepare Background Installer ---
    printf "\n"
    status wait "Preparing environment..."
    
    # Download lib.sh to /tmp so panel.sh can find it
    curl -sSL https://raw.githubusercontent.com/pterodactyl-installer/pterodactyl-installer/master/lib/lib.sh -o /tmp/lib.sh
    
    # Inject all variables into the environment
    export FQDN="$p_domain"
    export MYSQL_DB="panel"
    export MYSQL_USER="pterodactyl"
    export MYSQL_PASSWORD="$(openssl rand -base64 32)"
    export timezone="$p_timezone"
    export email="$p_email"
    export user_email="$p_email"
    export user_username="$p_user"
    export user_firstname="Admin"
    export user_lastname="User"
    export user_password="$p_pass"
    export ASSUME_SSL="false"
    export CONFIGURE_LETSENCRYPT="false"
    export CONFIGURE_FIREWALL="false"
    
    if [ "$selected_version" = "latest" ]; then
        export PANEL_DL_URL="https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz"
    else
        export PANEL_DL_URL="https://github.com/pterodactyl/panel/releases/download/${selected_version}/panel.tar.gz"
    fi
    
    status wait "Running installer..."
    printf "\n"
    
    # Fetch and execute the official panel.sh transparently
    curl -sSL https://raw.githubusercontent.com/pterodactyl-installer/pterodactyl-installer/master/panel/panel.sh -o /tmp/panel.sh
    source /tmp/panel.sh
    
    # Cleanup tmp files
    rm -f /tmp/lib.sh /tmp/panel.sh

    # --- Completion Message ---
    printf "\n"
    printf "  ${C_BORDER}┌──────────────────────────────────────────────────────┐${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}                                                      ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}       ${C_SUCCESS}${C_BOLD}✔  INSTALLATION COMPLETE${C_RESET}                        ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}                                                      ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}  ${C_DIM}Your Panel Live At:${C_RESET}                                ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}  ${C_ACCENT}${C_BOLD}http://${p_domain}${C_RESET}                                  ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}                                                      ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}└──────────────────────────────────────────────────────┘${C_RESET}\n"
    
    pause
}

# ═══════════════════════════════════════════════════════
#                MODULE: UPDATE PANEL
# ═══════════════════════════════════════════════════════

update_panel() {
    show_header "UPDATE PANEL"

    if ! $PANEL_INSTALLED; then
        status err "Panel not found in /var/www/pterodactyl"
        pause
        return
    fi

    status info "Fetching available versions..."
    local versions
    versions=$(fetch_versions "pterodactyl/panel")

    if [ -z "$versions" ]; then
        status err "Failed to fetch versions from GitHub"
        pause
        return
    fi

    printf "\n"
    printf "  ${C_BORDER}┌──────────────────────────────────────────────────────┐${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}  ${C_BRWHITE}${C_BOLD}SELECT VERSION${C_RESET}                                       ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}                                                      ${C_BORDER}│${C_RESET}\n"

    local i=1
    while IFS= read -r tag; do
        [ -z "$tag" ] && continue
        local num
        num=$(printf "%02d" "$i")
        if [ "$i" -eq 1 ]; then
            printf "  ${C_BORDER}│${C_RESET}    ${C_MENU_NUM}${C_BOLD}${num}${C_RESET}  ${C_SUCCESS}${tag}${C_RESET}  ${C_DIM}← latest${C_RESET}                             ${C_BORDER}│${C_RESET}\n"
        else
            printf "  ${C_BORDER}│${C_RESET}    ${C_GRAY}${num}${C_RESET}  ${C_DIM}${tag}${C_RESET}                                          ${C_BORDER}│${C_RESET}\n"
        fi
        ((i++))
    done <<< "$versions"

    printf "  ${C_BORDER}│${C_RESET}    ${C_GRAY}00${C_RESET}  ${C_DIM}Cancel${C_RESET}                                             ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}                                                      ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}└──────────────────────────────────────────────────────┘${C_RESET}\n"

    local default_tag
    default_tag=$(echo "$versions" | head -n1)

    printf "\n"
    ask_timeout "Select version" "01" version_choice

    if [ "$version_choice" = "00" ] || [ -z "$version_choice" ]; then
        status info "Update cancelled"
        pause
        return
    fi

    local selected_tag
    selected_tag=$(echo "$versions" | sed -n "${version_choice}p")
    [ -z "$selected_tag" ] && selected_tag="$default_tag"

    printf "\n"
    printf "  ${C_BORDER}┌──────────────────────────────────────────────────────┐${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}  ${C_DIM}Target${C_RESET}  ${C_SUCCESS}${C_BOLD}${selected_tag}${C_RESET}                                     ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}└──────────────────────────────────────────────────────┘${C_RESET}\n"
    printf "\n"

    if ! ask_confirm "Start update?"; then
        status info "Update cancelled"
        pause
        return
    fi

    printf "\n"
    status wait "Entering maintenance mode..."
    cd /var/www/pterodactyl
    php artisan down >> /dev/null 2>&1

    status wait "Clearing old files..."
    rm -rf /var/www/pterodactyl/*

    status wait "Downloading ${selected_tag}..."
    curl -Lso panel.tar.gz "https://github.com/pterodactyl/panel/releases/download/${selected_tag}/panel.tar.gz"

    status wait "Extracting archive..."
    tar -xzf panel.tar.gz
    chmod -R 755 storage/* bootstrap/cache/
    rm -f panel.tar.gz

    status wait "Installing dependencies..."
    COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader -q

    status wait "Running migrations..."
    php artisan view:clear -q
    php artisan config:clear -q
    php artisan migrate --seed --force -q

    status wait "Fixing permissions..."
    chown -R www-data:www-data /var/www/pterodactyl/*

    status wait "Restarting queue workers..."
    php artisan queue:restart -q
    php artisan up -q

    printf "\n"
    status ok "Panel updated to ${selected_tag}"
    pause
}

# ═══════════════════════════════════════════════════════
#                MODULE: UNINSTALL PANEL
# ═══════════════════════════════════════════════════════

uninstall_panel() {
    show_header "UNINSTALL PANEL"

    if ! $PANEL_INSTALLED; then
        status err "Panel is not installed"
        pause
        return
    fi

    printf "  ${C_ERROR}┌──────────────────────────────────────────────────────┐${C_RESET}\n"
    printf "  ${C_ERROR}│${C_RESET}  ${C_BRRED}${C_BOLD}⚠  DANGER ZONE${C_RESET}                                      ${C_ERROR}│${C_RESET}\n"
    printf "  ${C_ERROR}│${C_RESET}                                                      ${C_ERROR}│${C_RESET}\n"
    printf "  ${C_ERROR}│${C_RESET}  ${C_WHITE}This will permanently delete:${C_RESET}                         ${C_ERROR}│${C_RESET}\n"
    printf "  ${C_ERROR}│${C_RESET}    ${C_DIM}•  Panel files${C_RESET}                                     ${C_ERROR}│${C_RESET}\n"
    printf "  ${C_ERROR}│${C_RESET}    ${C_DIM}•  Database & users${C_RESET}                                  ${C_ERROR}│${C_RESET}\n"
    printf "  ${C_ERROR}│${C_RESET}    ${C_DIM}•  Nginx configuration${C_RESET}                              ${C_ERROR}│${C_RESET}\n"
    printf "  ${C_ERROR}│${C_RESET}    ${C_DIM}•  Queue workers & cron${C_RESET}                             ${C_ERROR}│${C_RESET}\n"
    printf "  ${C_ERROR}│${C_RESET}                                                      ${C_ERROR}│${C_RESET}\n"
    printf "  ${C_ERROR}│${C_RESET}  ${C_WARN}Wings will NOT be affected${C_RESET}                           ${C_ERROR}│${C_RESET}\n"
    printf "  ${C_ERROR}│${C_RESET}                                                      ${C_ERROR}│${C_RESET}\n"
    printf "  ${C_ERROR}└──────────────────────────────────────────────────────┘${C_RESET}\n"
    printf "\n"

    printf "  ${C_ERROR}${C_BOLD}Type 'DELETE' to confirm:${C_RESET} "
    local confirm
    read confirm

    if [ "$confirm" != "DELETE" ]; then
        status info "Uninstallation cancelled"
        pause
        return
    fi

    printf "\n"
    status wait "Stopping services..."
    systemctl stop pteroq.service 2>/dev/null
    systemctl disable pteroq.service 2>/dev/null
    rm -f /etc/systemd/system/pteroq.service
    systemctl daemon-reload

    status wait "Removing cron jobs..."
    crontab -l 2>/dev/null | grep -v 'php /var/www/pterodactyl/artisan schedule:run' | crontab - 2>/dev/null || true

    status wait "Deleting panel files..."
    rm -rf /var/www/pterodactyl

    status wait "Dropping database..."
    mysql -u root -e "DROP DATABASE IF EXISTS panel;" 2>/dev/null
    mysql -u root -e "DROP USER IF EXISTS 'pterodactyl'@'127.0.0.1';" 2>/dev/null
    mysql -u root -e "FLUSH PRIVILEGES;" 2>/dev/null

    status wait "Cleaning nginx..."
    rm -f /etc/nginx/sites-enabled/pterodactyl.conf
    rm -f /etc/nginx/sites-available/pterodactyl.conf
    systemctl reload nginx 2>/dev/null

    printf "\n"
    status ok "Panel removed successfully"
    pause
}

# ═══════════════════════════════════════════════════════
#                MODULE: CREATE USER
# ═══════════════════════════════════════════════════════

create_user() {
    show_header "USER MANAGEMENT"

    if ! $PANEL_INSTALLED; then
        status err "Panel not installed"
        pause
        return
    fi

    printf "  ${C_BORDER}┌──────────────────────────────────────────────────────┐${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}  ${C_BRWHITE}${C_BOLD}CREATE USER${C_RESET}                                         ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}                                                      ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}    ${C_MENU_NUM}${C_BOLD}01${C_RESET}  ${C_WHITE}Manual Setup${C_RESET}          ${C_DIM}·  Interactive${C_RESET}        ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}    ${C_MENU_NUM}${C_BOLD}02${C_RESET}  ${C_WHITE}Auto Admin${C_RESET}            ${C_DIM}·  Random Credentials${C_RESET} ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}    ${C_GRAY} 00${C_RESET}  ${C_GRAY}Back${C_RESET}                                             ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}                                                      ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}└──────────────────────────────────────────────────────┘${C_RESET}\n"
    printf "\n"

    ask_timeout "Select option" "00" user_choice

    case "$user_choice" in
        01)
            printf "\n"
            status info "Launching interactive user creation..."
            cd /var/www/pterodactyl
            php artisan p:user:make
            ;;
        02)
            printf "\n"
            status wait "Generating admin credentials..."

            local username="admin$(openssl rand -hex 2)"
            local password="$(openssl rand -base64 12)"
            local email="${username}@panel.local"
            local first="Admin"
            local last="User"

            cd /var/www/pterodactyl
            php artisan p:user:make -n \
                --email="$email" \
                --username="$username" \
                --password="$password" \
                --admin=1 \
                --name-first="$first" \
                --name-last="$last" -q 2>/dev/null

            if [ $? -eq 0 ]; then
                printf "\n"
                printf "  ${C_BORDER}┌──────────────────────────────────────────────────────┐${C_RESET}\n"
                printf "  ${C_BORDER}│${C_RESET}  ${C_SUCCESS}${C_BOLD}USER CREATED${C_RESET}                                         ${C_BORDER}│${C_RESET}\n"
                printf "  ${C_BORDER}│${C_RESET}                                                      ${C_BORDER}│${C_RESET}\n"
                printf "  ${C_BORDER}│${C_RESET}  ${C_DIM}Username${C_RESET}   ${C_WHITE}${username}${C_RESET}                                  ${C_BORDER}│${C_RESET}\n"
                printf "  ${C_BORDER}│${C_RESET}  ${C_DIM}Password${C_RESET}   ${C_HIGHLIGHT}${password}${C_RESET}                                  ${C_BORDER}│${C_RESET}\n"
                printf "  ${C_BORDER}│${C_RESET}  ${C_DIM}Email${C_RESET}      ${C_WHITE}${email}${C_RESET}                             ${C_BORDER}│${C_RESET}\n"
                printf "  ${C_BORDER}│${C_RESET}                                                      ${C_BORDER}│${C_RESET}\n"
                printf "  ${C_BORDER}└──────────────────────────────────────────────────────┘${C_RESET}\n"
            else
                printf "\n"
                status err "Failed to create user"
            fi
            ;;
        *)
            return
            ;;
    esac

    pause
}

# ═══════════════════════════════════════════════════════
#              MODULE: DOMAIN / SSL
# ═══════════════════════════════════════════════════════

domain_ssl() {
    show_header "DOMAIN & SSL"

    if ! $PANEL_INSTALLED; then
        status err "Panel not installed"
        pause
        return
    fi

    status info "Launching domain & SSL configuration..."
    sleep 1
    bash <(curl -fsSL https://raw.githubusercontent.com/nobita329/Nobita-Cloud/refs/heads/main/panel/pterodactyl/ssl.sh)
    pause
}

# ═══════════════════════════════════════════════════════
#              MODULE: PHPMYADMIN
# ═══════════════════════════════════════════════════════

phpmyadmin_setup() {
    show_header "PHPMYADMIN"

    status info "Launching phpMyAdmin setup..."
    sleep 1
    bash <(curl -fsSL https://raw.githubusercontent.com/nobita329/Nobita-Cloud/refs/heads/main/panel/pterodactyl/phpMyAdmin.sh)
    pause
}

# ═══════════════════════════════════════════════════════
#              MODULE: INSTALL WINGS
# ═══════════════════════════════════════════════════════

install_wings() {
    show_header "INSTALL WINGS"

    if $WINGS_INSTALLED; then
        status err "Wings is already installed"
        pause
        return
    fi

    printf "  ${C_BORDER}┌──────────────────────────────────────────────────────┐${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}  ${C_WARN}${C_BOLD}⚠  Prerequisites${C_RESET}                                     ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}                                                      ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}  ${C_DIM}•  Docker must be installed${C_RESET}                          ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}  ${C_DIM}•  Panel should be installed first${C_RESET}                   ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}  ${C_DIM}•  A Node must exist in the panel${C_RESET}                    ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}                                                      ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}└──────────────────────────────────────────────────────┘${C_RESET}\n"
    printf "\n"

    if ! ask_confirm "Proceed with Wings installation?"; then
        status info "Cancelled"
        pause
        return
    fi

    printf "\n"

    if ! command -v docker &>/dev/null; then
        status wait "Installing Docker..."
        curl -fsSL https://get.docker.com | bash -q
        systemctl enable docker -q
        systemctl start docker -q
    fi

    status wait "Creating directories..."
    mkdir -p /etc/pterodactyl
    mkdir -p /var/log/pterodactyl
    cd /etc/pterodactyl

    status wait "Downloading Wings binary..."
    curl -Lo wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64 -q
    chmod u+x wings

    status wait "Creating systemd service..."
    cat > /etc/systemd/system/wings.service << 'EOF'
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=524288
LimitNPROC=4096
ExecStart=/etc/pterodactyl/wings
Restart=on-failure
StartLimitIntervalSec=180
StartLimitBurst=30
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload -q
    systemctl enable wings -q

    printf "\n"
    printf "  ${C_BORDER}┌──────────────────────────────────────────────────────┐${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}  ${C_SUCCESS}${C_BOLD}WINGS INSTALLED${C_RESET}                                      ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}                                                      ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}  ${C_DIM}Next steps:${C_RESET}                                         ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}    ${C_WHITE}1.${C_RESET}  ${C_DIM}Create a Node in the panel${C_RESET}                     ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}    ${C_WHITE}2.${C_RESET}  ${C_DIM}Copy the configuration from the Node page${C_RESET}         ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}    ${C_WHITE}3.${C_RESET}  ${C_DIM}Use option 08 to apply configuration${C_RESET}            ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}                                                      ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}└──────────────────────────────────────────────────────┘${C_RESET}\n"

    pause
}

# ═══════════════════════════════════════════════════════
#              MODULE: CONFIGURE WINGS
# ═══════════════════════════════════════════════════════

configure_wings() {
    show_header "CONFIGURE WINGS"

    if ! $WINGS_INSTALLED; then
        status err "Wings not installed"
        pause
        return
    fi

    printf "  ${C_BORDER}┌──────────────────────────────────────────────────────┐${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}  ${C_BRWHITE}${C_BOLD}WINGS CONFIGURATION${C_RESET}                                  ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}                                                      ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}    ${C_MENU_NUM}${C_BOLD}01${C_RESET}  ${C_WHITE}Auto Configure${C_RESET}       ${C_DIM}·  Using Token${C_RESET}         ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}    ${C_MENU_NUM}${C_BOLD}02${C_RESET}  ${C_WHITE}Manual Edit${C_RESET}          ${C_DIM}·  Open config.yml${C_RESET}    ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}    ${C_MENU_NUM}${C_BOLD}03${C_RESET}  ${C_WHITE}Restart Wings${C_RESET}        ${C_DIM}·  Apply Changes${C_RESET}      ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}    ${C_GRAY} 00${C_RESET}  ${C_GRAY}Back${C_RESET}                                             ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}│${C_RESET}                                                      ${C_BORDER}│${C_RESET}\n"
    printf "  ${C_BORDER}└──────────────────────────────────────────────────────┘${C_RESET}\n"
    printf "\n"

    ask_timeout "Select option" "00" wings_choice

    case "$wings_choice" in
        01)
            printf "\n"
            ask_input "Panel URL" "" panel_url
            ask_input "Wings Token" "" wings_token

            if [ -z "$panel_url" ] || [ -z "$wings_token" ]; then
                status err "Panel URL and Token are required"
                pause
                return
            fi

            printf "\n"
            status wait "Generating configuration..."
            /etc/pterodactyl/wings configure \
                --panel-url "$panel_url" \
                --token "$wings_token" \
                --config /etc/pterodactyl/config.yml

            if [ -f /etc/pterodactyl/config.yml ]; then
                status ok "Configuration saved"
                status info "Use option 03 to restart and apply"
            else
                status err "Failed to generate configuration"
            fi
            ;;
        02)
            printf "\n"
            status info "Opening config.yml in nano..."
            sleep 1
            nano /etc/pterodactyl/config.yml
            ;;
        03)
            printf "\n"
            status wait "Restarting Wings..."
            systemctl restart wings
            sleep 2
            if systemctl is-active --quiet wings; then
                status ok "Wings is running"
            else
                status err "Wings failed to start"
                status info "Check logs: journalctl -u wings -n 50"
            fi
            ;;
        *)
            return
            ;;
    esac

    pause
}

# ═══════════════════════════════════════════════════════
#                   MAIN LOOP
# ═══════════════════════════════════════════════════════

main() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "\n  ${S_ERR}  ${C_WHITE}This script requires root privileges${C_RESET}\n"
        exit 1
    fi

    while true; do
        check_install_status
        show_main_menu

        local choice
        read choice

        case "$choice" in
            01|1)  install_panel ;;
            02|2)  update_panel ;;
            03|3)  uninstall_panel ;;
            04|4)  domain_ssl ;;
            05|5)  phpmyadmin_setup ;;
            06|6)  create_user ;;
            07|7)  install_wings ;;
            08|8)  configure_wings ;;
            0|"")  clear; exit 0 ;;
            *)     : ;;
        esac
    done
}

main
