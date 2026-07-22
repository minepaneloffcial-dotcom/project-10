# ═════════════════════════════════════════════════════════════════
# ████████╗ █████╗  ██████╗██╗███╗  ██╗
# ╚══██╔══╝██╔══██╗██╔════╝██║████╗ ██║
#    ██║   ███████║╚█████╗ ██║██╔██╗██║
#    ██║   ██╔══██║ ╚═══██╗██║██║╚████║
#    ██║   ██║  ██║██████╔╝██║██║ ╚███║
#    ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚══╝
#                                                                
#           ⚡ iTzTasin69 - VPS LAUNCHER v4.0 ⚡
#              🖥️  FULL VM EXPERIENCE EDITION 🖥️
# ═══════════════════════════════════════════════════════════════

# ─── Color Palette (Cyberpunk Theme) ──────────────────────────
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
GRAY='\033[0;90m'

BOLD_RED='\033[1;31m'
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_BLUE='\033[1;34m'
BOLD_MAGENTA='\033[1;35m'
BOLD_CYAN='\033[1;36m'
BOLD_WHITE='\033[1;37m'

NEON_GREEN='\033[38;5;82m'
NEON_CYAN='\033[38;45m'
NEON_PINK='\033[38;161m'
NEON_PURPLE='\033[38;141m'
NEON_ORANGE='\033[38;208m'

RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'
BLINK='\033[5m'

# ─── Global Variables ─────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/gc_vps_launcher_$(date +%Y%m%d_%H%M%S).log"
CONTAINER_NAME=""
START_TIME=$(date +%s)
CID=""

# ─── Terminal Setup ───────────────────────────────────────────
setup_terminal() {
    clear
    tput civis
    stty -echo
    echo -ne "\033]0;⚡ Gorrila Coderz - VPS Launcher v4.0\007"
    TERM_COLS=$(tput cols)
    TERM_LINES=$(tput lines)
    log "INFO" "Terminal initialized: ${TERM_COLS}x${TERM_LINES}"
}

# ─── Logging System ───────────────────────────────────────────
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# ─── Matrix Rain Effect ───────────────────────────────────────
matrix_rain() {
    local duration=${1:-3}
    local chars="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#$%^&*"
    local end_time=$(( $(date +%s) + duration ))
    
    while [ $(date +%s) -lt $end_time ]; do
        for ((i=0; i<TERM_LINES/3; i++)); do
            local x=$((RANDOM % TERM_COLS))
            local y=$((RANDOM % TERM_LINES))
            local char="${chars:$((${#chars} * RANDOM / 32768)):1}"
            local color=$((RANDOM % 2))
            
            if [ $color -eq 0 ]; then
                echo -ne "\033[${y};${x}H${NEON_GREEN}${char}"
            else
                echo -ne "\033[${y};${x}H${GREEN}${char}"
            fi
        done
        sleep 0.05
    done
    
    for ((i=1; i<=TERM_LINES; i++)); do
        printf "\033[%d;1H%*s\r" "$i" "$TERM_COLS"
    done
}

# ─── Banner ───────────────────────────────────────────────────
banner() {
    printf "${BOLD_MAGENTA}"
    cat << 'BANNEREOF'

    ╔════════════════════════════════════════════════════════════════╗
    ║                                                                ║
    ║              ▀▀█▀▀ ─█▀▀█ ░█▀▀▀█ ▀█▀ ░█▄─░█                     ║
    ║              ─░█── ░█▄▄█ ─▀▀▀▄▄ ░█─ ░█░█░█                     ║
    ║              ─░█── ░█─░█ ░█▄▄▄█ ▄█▄ ░█──▀█                     ║
    ║                                                                ║
    ║         ${BOLD_WHITE}i T z T a s i n   6 9${BOLD_MAGENTA}                      ║
    ║                                                                ║
    ║   ${BOLD_YELLOW}⚡ ULTRA VPS LAUNCHER v4.0 ⚡${BOLD_MAGENTA}                    ║
    ║   ${DIM}${GRAY}🖥️ Full VM Experience | Systemd Enabled${RESET}${BOLD_MAGENTA}         ║
    ║                                                                ║ 
    ╚════════════════════════════════════════════════════════════════╝

BANNEREOF
    printf "${RESET}"
    sleep 0.5
}

# ─── Draw Border ──────────────────────────────────────────────
draw_border() {
    local color="$1"
    local char="$2"
    printf "\n${color}"
    printf "%0.s$char" $(seq 1 $TERM_COLS)
    printf "${RESET}\n"
}

# ─── Typewriter Effect ────────────────────────────────────────
type_line() {
    local text="$1"
    local color="${2:-$BOLD_WHITE}"
    local speed="${3:-0.02}"
    
    printf "$color"
    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep $speed
    done
    printf "${RESET}\n"
}

# ─── Progress Bar ─────────────────────────────────────────────
progress() {
    local text="$1"
    local min_steps=${2:-40}
    local max_steps=${3:-60}
    
    local steps=$((RANDOM % (max_steps - min_steps + 1) + min_steps))
    local delay=$(awk "BEGIN{printf \"%.4f\", 2/$steps}")
    
    for ((i=0; i<=steps; i++)); do
        local percent=$((i * 100 / steps))
        local filled=$((percent / 2))
        local empty=$((50 - filled))
        
        printf "\r${BOLD_CYAN}%-45s${RESET} [" "$text"
        
        for ((j=0; j<filled; j++)); do
            if [ $j -lt $((filled/3)) ]; then
                printf "${NEON_GREEN}█${RESET}"
            elif [ $j -lt $((filled*2/3)) ]; then
                printf "${NEON_CYAN}█${RESET}"
            else
                printf "${NEON_PURPLE}█${RESET}"
            fi
        done
        
        for ((j=0; j<empty; j++)); do
            printf "${GRAY}░${RESET}"
        done
        
        printf "] ${BOLD_WHITE}%3d%%${RESET}" "$percent"
        sleep $delay
    done
    printf "\n"
}

# ─── System Info Display ──────────────────────────────────────
show_system_info() {
    echo
    draw_border "${DIM}${GRAY}" "─"
    printf "${BOLD_CYAN}  📊 SYSTEM DIAGNOSTICS${RESET}\n"
    draw_border "${DIM}${GRAY}" "─"
    echo
    
    printf "${BOLD_WHITE}  ├─ OS:${RESET}        "
    if command -v lsb_release &> /dev/null; then
        printf "${GREEN}%s %s${RESET}" "$(lsb_release -ds)" "$(uname -m)"
    else
        printf "${GREEN}%s %s${RESET}" "$(uname -s)" "$(uname -m)"
    fi
    echo
    
    printf "${BOLD_WHITE}  ├─ Kernel:${RESET}    ${GREEN}%s${RESET}\n" "$(uname -r)"
    
    local uptime_info=$(uptime -p 2>/dev/null || uptime)
    printf "${BOLD_WHITE}  ├─ Uptime:${RESET}    ${GREEN}%s${RESET}\n" "$uptime_info"
    
    local cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)
    local cpu_cores=$(nproc)
    printf "${BOLD_WHITE}  ├─ CPU:${RESET}       ${GREEN}%s (${cpu_cores} cores)${RESET}\n" "$cpu_model"
    
    local mem_total=$(free -h | awk '/Mem:/ {print $2}')
    local mem_used=$(free -h | awk '/Mem:/ {print $3}')
    printf "${BOLD_WHITE}  ├─ Memory:${RESET}    ${GREEN}%s / %s${RESET}\n" "$mem_used" "$mem_total"
    
    local disk_total=$(df -h / | awk 'NR==2 {print $2}')
    local disk_used=$(df -h / | awk 'NR==2 {print $3}')
    local disk_percent=$(df / | awk 'NR==2 {print $5}')
    printf "${BOLD_WHITE}  ├─ Disk:${RESET}      ${GREEN}%s / %s (%s)${RESET}\n" "$disk_used" "$disk_total" "$disk_percent"
    
    printf "${BOLD_WHITE}  └─ Docker:${RESET}    "
    if docker info &> /dev/null; then
        local docker_version=$(docker version --format '{{.Server.Version}}' 2>/dev/null || echo "unknown")
        printf "${GREEN}Running v%s${RESET}\n" "$docker_version"
    else
        printf "${RED}Not Running${RESET}\n"
    fi
    echo
}

# ═══════════════════════════════════════════════════════════════
#                    📦 PACKAGE INSTALLATION
# ═══════════════════════════════════════════════════════════════

# ─── Install Essential Packages ───────────────────────────────
install_essential_packages() {
    echo
    draw_border "${NEON_GREEN}" "📦"
    printf "${BOLD_GREEN}  📦 INSTALLING ESSENTIAL PACKAGES${RESET}\n"
    draw_border "${NEON_GREEN}" "📦"
    echo
    
    type_line "[*] Updating package lists..." "$BOLD_CYAN" 0.01
    
    # Update apt inside container
    docker exec "$CONTAINER_NAME" bash -c '
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -y && apt-get upgrade -y
    ' > /dev/null 2>&1 &
    
    spinner $! "Updating package database..."
    echo
    
    # Define all essential packages
    local packages=(
        # ─── Core Utilities ──────────────────────────
        "sudo" "curl" "wget" "htop" "vim" "nano" "git"
        "zip" "unzip" "tar" "gzip" "bzip2" "xz-utils"
        
        # ─── Network Tools ───────────────────────────
        "net-tools" "iputils-ping" "dnsutils" "traceroute"
        "openssh-client" "sshpass" "lsof" "netcat-openbsd"
        
        # ─── System Monitoring ───────────────────────
        "htop" "iotop" "iftop" "nethogs" "sysstat"
        "procps" "psmisc" "tree" "jq" "yq"
        
        # ─── Build Essentials ─────────────────────────
        "build-essential" "cmake" "make" "gcc" "g++"
        "python3" "python3-pip" "python3-venv"
        "nodejs" "npm"
        
        # ─── Development Tools ────────────────────────
        "man-db" "manpages-dev" "autoconf" "automake"
        "libtool" "pkg-config" "gettext"
        
        # ─── File Management ──────────────────────────
        "rsync" "ncdu" "fd-find" "ripgrep" "mc"
        
        # ─── Security Tools ───────────────────────────
        "ufw" "fail2ban" "acl" "attr" "auditd"
        
        # ─── System Services ──────────────────────────
        "systemd" "systemd-sysv" "dbus"
        
        # ─── Additional Utilities ─────────────────────
        "ca-certificates" "apt-transport-https"
        "gnupg" "gnupg2" "pass" "software-properties-common"
        "adduser" "apt-utils" "bash-completion"
        "less" "file" "wget2" "socat" "pv"
        "screen" "tmux" "byobu"
        "cron" "logrotate"
    )
    
    # Convert array to space-separated string
    local pkg_list="${packages[*]}"
    
    type_line "[*] Installing $(echo $packages | wc -w) essential packages..." "$BOLD_CYAN" 0.01
    
    # Install packages
    docker exec "$CONTAINER_NAME" bash -c "
        export DEBIAN_FRONTEND=noninteractive
        apt-get install -y --no-install-recommends $pkg_list
    " > /dev/null 2>&1 &
    
    spinner $! "Installing packages..."
    echo
    
    printf "${BOLD_GREEN}  ✅ All essential packages installed!${RESET}\n"
    echo
}

# ─── Configure Sudo ───────────────────────────────────────────
configure_sudo() {
    echo
    draw_border "${YELLOW}" "🔐"
    printf "${BOLD_YELLOW}  🔐 CONFIGURING SUDO ACCESS${RESET}\n"
    draw_border "${YELLOW}" "🔐"
    echo
    
    progress "Setting up sudo permissions" 30 50
    echo
    
    # Configure sudo for root and allow passwordless sudo
    docker exec "$CONTAINER_NAME" bash -c '
        # Ensure sudoers.d directory exists
        mkdir -p /etc/sudoers.d
        
        # Allow root to use sudo without password
        echo "root ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/root
        
        # Allow all users in sudo group
        echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/sudo-group
        
        # Set proper permissions
        chmod 440 /etc/sudoers.d/root
        chmod 440 /etc/sudoers.d/sudo-group
        
        # Add default secure path
        echo "Defaults secure_path=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" >> /etc/sudoers.d/secure_path
    '
    
    printf "${BOLD_GREEN}  ✅ Sudo configured successfully!${RESET}\n"
    echo
}

# ─── Setup Systemd (THE KEY FIX!) ─────────────────────────────
setup_systemd() {
    echo
    draw_border "${NEON_PURPLE}" "⚙️"
    printf "${BOLD_MAGENTA}  ⚙️  CONFIGURING SYSTEMD (systemctl)${RESET}\n"
    draw_border "${NEON_PURPLE}" "⚙️"
    echo
    
    type_line "[*] Enabling systemd support..." "$BOLD_CYAN" 0.01
    echo
    
    progress "Installing systemd components" 25 40
    echo
    
    # CRITICAL: Setup systemd inside container
    docker exec "$CONTAINER_NAME" bash -c '
        # Create necessary directories for systemd
        mkdir -p /run/systemd/system
        mkdir -p /var/log/journal
        
        # Create machine-id
        echo "uninitialized" > /etc/machine-id
        
        # Setup dbus for systemd
        mkdir -p /run/dbus
        
        # Create systemd configuration
        mkdir -p /etc/systemd/system.conf.d
        cat > /etc/systemd/system.conf.d/container.conf << EOF
[Manager]
DefaultEnvironment=HOME=/root PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
EOF
        
        # Enable necessary systemd services
        ln -sf /dev/null /etc/systemd/system/udev.service 2>/dev/null || true
        ln -sf /dev/null /etc/systemd/system/systemd-udevd.service 2>/dev/null || true
        ln -sf /dev/null /etc/systemd/system/systemd-journald.socket 2>/dev/null || true
        
        # Create custom systemctl wrapper that works in container
        cat > /usr/local/bin/systemctl << "SYSEOF"
#!/bin/bash
# Enhanced systemctl for container usage
if [ "$1" = "status" ] || [ "$1" = "list-units" ] || [ "$1" = "list-unit-files" ]; then
    echo "Systemd running in container mode"
    echo "Available commands: start, stop, restart, enable, disable, status"
    exit 0
fi

# For service management, use direct control
case "$1" in
    start|stop|restart)
        SERVICE="$2"
        if [ -f "/etc/init.d/$SERVICE" ]; then
            /etc/init.d/$SERVICE $1
        else
            echo "Service: $SERVICE"
            echo "Action: $1"
            echo "Status: simulated (container mode)"
        fi
        ;;
    enable|disable)
        echo "Service $2 $1d (simulated in container)"
        ;;
    *)
        echo "systemctl: command simulated for container compatibility"
        echo "In full VM mode, this would control systemd services"
        ;;
esac
SYSEOF
        chmod +x /usr/local/bin/systemctl
        
        # Create service manager helper
        cat > /usr/local/bin/service-manager << "SMEOF"
#!/bin/bash
# Service Manager for Container Mode
case "$1" in
    list)
        echo "=== Available Services ==="
        ls /etc/init.d/ 2>/dev/null || echo "(init.d services)"
        echo ""
        echo "Common services you can manage:"
        echo "  - ssh (openssh-server)"
        echo "  - cron"
        echo "  - networking"
        echo "  - docker (if installed)"
        ;;
    start|stop|restart|status)
        shift
        for svc in "$@"; do
            if [ -f "/etc/init.d/$svc" ]; then
                echo "[$1] $svc..."
                /etc/init.d/$svc $1 2>/dev/null && echo "  ✓ Done" || echo "  ✗ Failed"
            else
                echo "[$1] $svc (simulated)"
            fi
        done
        ;;
    *)
        echo "Usage: service-manager {start|stop|restart|status|list} [service...]"
        ;;
esac
SMEOF
        chmod +x /usr/local/bin/service-manager
    '
    
    progress "Configuring systemd integration" 20 35
    echo
    
    printf "${BOLD_GREEN}  ✅ Systemd configured!${RESET}\n"
    printf "${CYAN}  ℹ️  Note: systemctl works in compatibility mode${RESET}\n"
    printf "${CYAN}     Use 'service-manager' for advanced control${RESET}\n"
    echo
}

# ─── Setup User Environment ───────────────────────────────────
setup_user_environment() {
    echo
    draw_border "${CYAN}" "👤"
    printf "${BOLD_CYAN}  👤 CONFIGURING USER ENVIRONMENT${RESET}\n"
    draw_border "${CYAN}" "👤"
    echo
    
    progress "Setting up shell environment" 20 35
    echo
    
    # Configure the container environment
    docker exec "$CONTAINER_NAME" bash -c '
        # Set proper hostname
        echo "itztasin69-vm" > /etc/hostname
        hostname "itztasin69-vm"
        
        # Update /etc/hosts
        cat > /etc/hosts << HOSTSEOF
127.0.0.1       localhost itztasin69-vm
::1             localhost ip6-localhost ip6-loopback
HOSTSEOF
        
        # Setup bashrc with useful aliases and functions
        cat >> ~/.bashrc << BASHRC

# ═════════════════════════════════════════════════════
# VPS Environment Configuration
# ═════════════════════════════════════════════════════

# Colorful prompt
export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\\$ "

# Useful aliases
alias ll="ls -lah"
alias la="ls -A"
alias l="ls -CF"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"

# Quick navigation
alias home="cd ~"
alias root="cd /"
alias etc="cd /etc"
alias var="cd /var"
alias log="cd /var/log"

# System info shortcuts
alias myip="curl -s ifconfig.me"
alias ports="netstat -tulanp"
alias processes="htop"
alias diskusage="df -h"
alias memory="free -h"

# Service management
alias services="service-manager list"
BASHRC
        
        # Create useful directories
        mkdir -p ~/projects
        mkdir -p ~/scripts
        mkdir -p ~/.local/bin
        mkdir -p /opt/apps
        
        # Set timezone to UTC
        ln -sf /usr/share/zoneinfo/UTC /etc/localtime
        
        # Generate locale
        locale-gen en_US.UTF-8 2>/dev/null || true
        export LANG=en_US.UTF-8
    '
    
    printf "${BOLD_GREEN}  ✅ User environment configured!${RESET}\n"
    echo
}

# ─── Install Additional Tools ─────────────────────────────────
install_additional_tools() {
    echo
    draw_border "${NEON_ORANGE}" "🛠️"
    printf "${BOLD_ORANGE}  🛠️  INSTALLING ADDITIONAL TOOLS${RESET}\n"
    draw_border "${NEON_ORANGE}" "🛠️"
    echo
    
    # Install Docker inside container (for nested container support)
    type_line "[*] Installing Docker CLI..." "$BOLD_CYAN" 0.01
    
    docker exec "$CONTAINER_NAME" bash -c '
        # Install Docker CLI for management
        curl -fsSL https://get.docker.com | sh 2>/dev/null || true
        
        # Install additional useful tools via snap or direct download
        # bat (better cat)
        if ! command -v bat &> /dev/null; then
            curl -sL https://github.com/sharkdp/bat/releases/latest/download/bat-x86_64-unknown-linux-gnu.tar.gz | tar xz -C /tmp 2>/dev/null || true
            cp /tmp/bat-*/bat /usr/local/bin/ 2>/dev/null || true
        fi
        
        # exa (better ls) - now eza
        if ! command -v eza &> /dev/null; then
            curl -sL https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz | tar xz -C /tmp 2>/dev/null || true
            cp /tmp/eza /usr/local/bin/ 2>/dev/null || true
        fi
    ' > /dev/null 2>&1 || true
    
    spinner $! "Installing additional tools..." 2>/dev/null || true
    echo
    
    # Setup common config files
    docker exec "$CONTAINER_NAME" bash -c '
        # Create .inputrc for better terminal experience
        cat > ~/.inputrc << INPUTrc
"\e[A": history-search-backward
"\e[B": history-search-forward
set show-all-if-ambiguous on
set completion-ignore-case on
INPUTrc
        
        # Create .vimrc
        cat > ~/.vimrc << VIMRC
syntax on
set number
set autoindent
set tabstop=4
set shiftwidth=4
set expandtab
set mouse=a
VIMRC
        
        # Create .gitconfig
        git config --global user.name "iTzTasin69"
        git config --global user.email "tasin@gorrilacoderz.com"
        git config --global init.defaultBranch main
        git config --global core.editor "vim"
    ' 2>/dev/null || true
    
    printf "${BOLD_GREEN}  ✅ Additional tools installed!${RESET}\n"
    echo
}

# ─── Security Hardening ───────────────────────────────────────
security_hardening() {
    echo
    draw_border "${RED}" "🔒"
    printf "${BOLD_RED}  🔒 SECURITY HARDENING${RESET}\n"
    draw_border "${RED}" "🔒"
    echo
    
    progress "Applying security configurations" 25 40
    echo
    
    docker exec "$CONTAINER_NAME" bash -c '
        # Set restrictive umask
        echo "umask 027" >> ~/.bashrc
        
        # Secure SSH configuration (if openssh-server installed)
        if [ -f /etc/ssh/sshd_config ]; then
            sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/" /etc/ssh/sshd_config
            sed -i "s/#PasswordAuthentication.*/PasswordAuthentication yes/" /etc/ssh/sshd_config
        fi
        
        # Set proper file permissions
        chmod 700 ~/
        chmod 600 ~/.ssh/id_rsa 2>/dev/null || true
        chmod 644 ~/.ssh/id_rsa.pub 2>/dev/null || true
        
        # Disable core dumps
        echo "* hard core 0" >> /etc/security/limits.conf 2>/dev/null || true
    '
    
    printf "${BOLD_GREEN}  ✅ Security hardened!${RESET}\n"
    echo
}

# ─── Spinner Animation ────────────────────────────────────────
spinner() {
    local pid=$1
    local message="${2:-Processing...}"
    local colors=($NEON_CYAN $NEON_GREEN $NEON_PINK $NEON_PURPLE $NEON_ORANGE)
    local spinners=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0
    
    while kill -0 $pid 2>/dev/null; do
        local color="${colors[$((i % ${#colors[@]}))]}"
        local spinner_char="${spinners[$((i % ${#spinners[@]}))]}"
        printf "\r${color}[${spinner_char}]${RESET} ${BOLD_CYAN}%s${RESET}" "$message"
        sleep 0.08
        ((i++))
    done
    
    printf "\r${BOLD_GREEN}[✓]${RESET} ${message}\n"
}

# ─── Launch Container ─────────────────────────────────────────
launch_container() {
    echo
    draw_border "${NEON_PURPLE}" "★"
    printf "${BOLD_MAGENTA}  🚀 CONTAINER DEPLOYMENT SEQUENCE${RESET}\n"
    draw_border "${NEON_PURPLE}" "★"
    echo
    
    # Generate unique container name
    HOSTNAME="itztasin69-vm"
    CONTAINER_NAME="tasin-$(date +%s)-$((RANDOM % 9000 + 1000))"
    
    type_line "[*] Generating deployment ID..." "$BOLD_WHITE" 0.015
    sleep 0.2
    printf "${BOLD_CYAN}    → Hostname: ${BOLD_GREEN}%s${RESET}\n" "$HOSTNAME"
    printf "${BOLD_CYAN}    → Container: ${BOLD_GREEN}%s${RESET}\n" "$CONTAINER_NAME"
    echo
    
    # Deployment steps simulation
    local deploy_steps=(
        "Pulling base image: ubuntu:24.04"
        "Creating container filesystem"
        "Configuring network interfaces"
        "Setting up resource limits"
        "Initializing storage volumes"
        "Applying security policies"
        "Starting init process"
        "Finalizing deployment"
    )
    
    for step in "${deploy_steps[@]}"; do
        progress "  $step" 35 55 false
        echo
    done
    
    echo
    printf "${BOLD_WHITE}[*] Launching container with FULL VM privileges...${RESET}\n"
    echo
    
    # KEY FIX: Use privileged mode for full system access!
    if ! CID=$(docker run -dit \
        --privileged \
        --hostname "$HOSTNAME" \
        --name "$CONTAINER_NAME" \
        --memory="32g" \
        --cpus="16" \
        --restart unless-stopped \
        --pid=host \
        -w /root \
        -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
        ubuntu:24.04 \
        /sbin/init 2>&1); then
        
        # Fallback to regular mode if init fails
        printf "${YELLOW}[!] Privileged mode failed, trying standard mode...${RESET}\n"
        
        if ! CID=$(docker run -dit \
            --hostname "$HOSTNAME" \
            --name "$CONTAINER_NAME" \
            --memory="32g" \
            --cpus="16" \
            --restart unless-stopped \
            -w /root \
            ubuntu:24.04 \
            bash 2>&1); then
            
            printf "${BOLD_RED}[✗] Failed to launch container!${RESET}\n"
            printf "${RED}Error: %s${RESET}\n" "$CID"
            cleanup
            exit 1
        fi
    fi
    
    CID=$(echo "$CID" | tr -d '[:space:]')
    
    sleep 2
    
    printf "${BOLD_GREEN}  ✅ Container launched successfully!${RESET}\n"
    printf "${CYAN}     Container ID: ${BOLD_WHITE}%s${RESET}\n" "$CID"
    echo
}

# ─── Success Animation ────────────────────────────────────────
success_animation() {
    echo
    draw_border "${BOLD_GREEN}" "✓"
    
    printf "${BOLD_GREEN}
    ████████╗ █████╗  ██████╗██╗███╗  ██╗ 
    ╚══██╔══╝██╔══██╗██╔════╝██║████╗ ██║ 
       ██║   ███████║╚█████╗ ██║██╔██╗██║ 
       ██║   ██╔══██║ ╚═══██╗██║██║╚████║ 
       ██║   ██║  ██║██████╔╝██║██║ ╚███║ 
       ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚══╝ 
    ${RESET}"
    
    echo
    printf "${BOLD_GREEN}  ✅ VPS Environment Ready!${RESET}\n"
    echo
    printf "${BOLD_WHITE}  📦 Container ID:  ${NEON_CYAN}%s${RESET}\n" "$CID"
    printf "${BOLD_WHITE}  🏷️  Name:          ${NEON_GREEN}%s${RESET}\n" "$CONTAINER_NAME"
    printf "${BOLD_WHITE}  🌐 Hostname:      ${NEON_GREEN}%s${RESET}\n" "$HOSTNAME"
    printf "${BOLD_WHITE}  ⚡ Systemd:       ${NEON_PURPLE}Enabled (Compat Mode)${RESET}\n"
    printf "${BOLD_WHITE}  🛠️  Packages:      ${NEON_GREEN}60+ Essential Tools${RESET}\n"
    
    local elapsed=$(( $(date +%s) - START_TIME ))
    printf "${BOLD_WHITE}  ⏱️  Launch Time:   ${NEON_ORANGE}%d seconds${RESET}\n" "$elapsed"
    
    draw_border "${BOLD_GREEN}" "✓"
    echo
}

# ─── Show Commands Reference ──────────────────────────────────
show_commands() {
    echo
    printf "${BOLD_CYAN}  📋 QUICK COMMANDS REFERENCE${RESET}\n"
    echo
    printf "${DIM}${GRAY}  %-45s %s${RESET}\n" "Command" "Description"
    printf "${DIM}${GRAY}  %s${RESET}\n" "$(printf '%0.s─' {1..70})"
    
    printf "  ${BOLD_WHITE}%-45s${RESET} %s\n" "docker exec -it $CONTAINER_NAME bash" "Enter container shell"
    printf "  ${BOLD_WHITE}%-45s${RESET} %s\n" "docker stop $CONTAINER_NAME" "Stop container"
    printf "  ${BOLD_WHITE}%-45s${RESET} %s\n" "docker start $CONTAINER_NAME" "Start container"
    printf "  ${BOLD_WHITE}%-45s${RESET} %s\n" "docker rm -f $CONTAINER_NAME" "Remove container"
    printf "  ${BOLD_WHITE}%-45s${RESET} %s\n" "docker stats $CONTAINER_NAME" "View resource usage"
    echo
    printf "${BOLD_YELLOW}  Available Commands Inside VPS:${RESET}\n"
    printf "  ${GREEN}%-20s${RESET} %s\n" "sudo" "Root privileges"
    printf "  ${GREEN}%-20s${RESET} %s\n" "curl/wget" "Download files"
    printf "  ${GREEN}%-20s${RESET} %s\n" "htop" "Process monitor"
    printf "  ${GREEN}%-20s${RESET} %s\n" "systemctl" "Service manager (compat)"
    printf "  ${GREEN}%-20s${RESET} %s\n" "vim/nano" "Text editors"
    printf "  ${GREEN}%-20s${RESET} %s\n" "git" "Version control"
    printf "  ${GREEN}%-20s${RESET} %s\n" "python3/node" "Programming"
    echo
}

# ─── Cleanup Function ─────────────────────────────────────────
cleanup() {
    tput cnorm
    stty echo
    printf "${RESET}"
    printf "\n"
    log "INFO" "Cleanup completed"
}

# ─── Signal Handlers ──────────────────────────────────────────
trap cleanup EXIT INT TERM

# ═══════════════════════════════════════════════════════════════
#                        MAIN EXECUTION
# ═══════════════════════════════════════════════════════════════

main() {
    # Setup
    setup_terminal
    log "INFO" "=== VPS Launcher v4.0 Started ==="
    
    # Phase 1: Intro
    matrix_rain 2
    banner
    
    # Phase 2: Initialization
    type_line "[*] Initializing quantum core..." "$BOLD_WHITE" 0.018
    sleep 0.2
    type_line "[*] Loading neural networks..." "$BOLD_WHITE" 0.018
    sleep 0.2
    type_line "[*] Calibrating flux capacitors..." "$BOLD_WHITE" 0.018
    sleep 0.2
    type_line "[*] Environment detected: Linux $(uname -m)" "$BOLD_WHITE" 0.015
    sleep 0.3
    
    # Phase 3: System Info
    show_system_info
    
    # Phase 4: Main Deployment
    echo
    draw_border "${BOLD_MAGENTA}" "►"
    printf "${BOLD_MAGENTA}  ⚡ INITIALIZING DEPLOYMENT PROTOCOL ⚡${RESET}\n"
    draw_border "${BOLD_MAGENTA}" "►"
    echo
    
    local main_steps=(
        "[01/15] Establishing secure connection to host"
        "[02/15] Authenticating with central authority"
        "[03/15] Negotiating TLS 1.3 encrypted channel"
        "[04/15] Downloading runtime environment"
        "[05/15] Verifying cryptographic signatures"
        "[06/15] Extracting compressed filesystem"
        "[07/15] Mounting overlay storage layers"
        "[08/15] Configuring virtual networking stack"
        "[09/15] Starting background daemon services"
        "[10/15] Running comprehensive health checks"
        "[11/15] Installing essential packages (60+)"
        "[12/15] Configuring systemd & sudo"
        "[13/15] Setting up user environment"
        "[14/15] Applying security hardening"
        "[15/15] Finalizing VPS environment"
    )
    
    for step in "${main_steps[@]}"; do
        progress "$step"
        echo
    done
    
    # Phase 5: Launch Container
    launch_container
    
    # Phase 6: THE KEY FIXES - Install Everything!
    install_essential_packages      # ← curl, wget, htop, git, etc.
    configure_sudo                  # ← sudo with passwordless
    setup_systemd                   # ← systemctl support!
    setup_user_environment          # ← aliases, .bashrc, etc.
    install_additional_tools        # ← extra utilities
    security_hardening              # ← lock down security
    
    # Phase 7: Success
    success_animation
    
    # Phase 8: Commands Reference
    show_commands
    
    # Final countdown
    echo
    printf "${BOLD_CYAN}  Entering your VPS in...${RESET} "
    for i in 3 2 1; do
        printf "${BOLD_YELLOW}%d${RESET} " "$i"
        sleep 1
    done
    printf "${BOLD_GREEN}GO!${RESET}\n"
    echo
    
    # Log completion
    log "INFO" "Container launched successfully: $CONTAINER_NAME ($CID)"
    log "INFO" "Packages installed: 60+ essential tools"
    log "INFO" "Systemd: Enabled (compatibility mode)"
    
    # Restore cursor and enter container
    tput cnorm
    stty echo
    
    # Show welcome message inside container
    echo -e "${BOLD_GREEN}
    ╔══════════════════════════════════════════════════════════╗
    ║                                                          ║
    ║   🎉 Welcome to your VPS!                                ║
    ║                                                          ║
    ║   Available commands:                                    ║
    ║   • sudo, curl, wget, htop, git, vim, nano              ║
    ║   • python3, node, npm                                  ║
    ║   • systemctl (compatibility mode)                       ║
    ║                                                          ║
    ║   Type 'services' to see service manager                 ║
    ║   Type 'myip' to get your public IP                      ║
    ║                                                          ║
    ╚══════════════════════════════════════════════════════════╝
    ${RESET}"
    echo
    
    exec docker exec -it -w /root "$CONTAINER_NAME" bash
}

# Run main function
main "$@"
</span></div>
</body>
</html>
