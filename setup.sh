#!/bin/bash

#############################################################################
# SCRIPT OTOMASI KONFIGURASI DEBIAN 11 (IP ADDRESS - DNS SERVER)
# Berdasarkan Modul UJIKOM
# 
# Script ini mengotomasi langkah-langkah konfigurasi:
# 1. Setting IP Address
# 2. Setting Repository
# 3. Setting DNS Server (BIND9)
#
# Requirements: Debian 11, akses root/sudo
# Author: Your Name
# Date: 2024
#############################################################################

set -e  # Exit on error

# WARNA OUTPUT
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# FUNGSI HELPER
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# CEK APAKAH SCRIPT DIJALANKAN SEBAGAI ROOT
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Script harus dijalankan sebagai root!"
        echo "Gunakan: sudo bash debian-config-automation.sh"
        exit 1
    fi
    print_success "Script dijalankan sebagai root"
}

# FUNGSI INPUT DENGAN VALIDASI
get_network_interface() {
    print_info "Daftar interface jaringan yang tersedia:"
    ip link | grep -E "^[0-9]+:" | awk '{print $2}' | sed 's/://'
    
    echo ""
    read -p "Masukkan nama interface (misal: enp2s0, eth0): " INTERFACE
    
    if ! ip link show "$INTERFACE" > /dev/null 2>&1; then
        print_error "Interface $INTERFACE tidak ditemukan!"
        exit 1
    fi
    print_success "Interface dipilih: $INTERFACE"
}

get_ip_config() {
    read -p "Masukkan IP address dengan CIDR (misal: 192.168.100.11/24): " IP_ADDRESS
    
    # Validasi format IP
    if ! [[ $IP_ADDRESS =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]; then
        print_error "Format IP tidak valid!"
        exit 1
    fi
    print_success "IP Address: $IP_ADDRESS"
    
    read -p "Masukkan Gateway (misal: 192.168.100.1): " GATEWAY
    
    if ! [[ $GATEWAY =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        print_error "Format Gateway tidak valid!"
        exit 1
    fi
    print_success "Gateway: $GATEWAY"
}

get_dns_config() {
    read -p "Masukkan nama domain (misal: tkjsmkdt.org): " DOMAIN_NAME
    print_success "Domain Name: $DOMAIN_NAME"
    
    read -p "Masukkan nameserver local (misal: 192.168.100.11): " NAMESERVER_LOCAL
    print_success "Nameserver Local: $NAMESERVER_LOCAL"
    
    read -p "Masukkan nameserver forwarder (misal: 8.8.8.8): " NAMESERVER_FORWARD
    print_success "Nameserver Forwarder: $NAMESERVER_FORWARD"
}

# STEP 1: KONFIGURASI IP ADDRESS
configure_ip_address() {
    print_header "STEP 1: KONFIGURASI IP ADDRESS"
    
    # Backup file original
    if [[ -f /etc/network/interfaces ]]; then
        cp /etc/network/interfaces /etc/network/interfaces.backup
        print_success "Backup file interfaces dibuat: /etc/network/interfaces.backup"
    fi
    
    # Buat konfigurasi interfaces
    cat > /etc/network/interfaces <<EOF
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# Primary network interface
auto $INTERFACE
iface $INTERFACE inet static
    address $IP_ADDRESS
    gateway $GATEWAY
EOF
    
    print_success "File /etc/network/interfaces dikonfigurasi"
    
    # Apply perubahan IP
    print_info "Menerapkan konfigurasi IP..."
    systemctl restart networking
    sleep 2
    
    print_success "Konfigurasi IP Address selesai"
}

# STEP 2: KONFIGURASI RESOLV.CONF
configure_resolv_conf() {
    print_header "STEP 2: KONFIGURASI DNS RESOLVER"
    
    # Backup file original
    if [[ -f /etc/resolv.conf ]]; then
        cp /etc/resolv.conf /etc/resolv.conf.backup
        print_success "Backup file resolv.conf dibuat"
    fi
    
    # Ekstrak IP lokal tanpa CIDR
    IP_ONLY=$(echo $IP_ADDRESS | cut -d'/' -f1)
    
    # Buat konfigurasi resolv.conf
    cat > /etc/resolv.conf <<EOF
# DNS Configuration
nameserver $IP_ONLY
nameserver $NAMESERVER_FORWARD
EOF
    
    print_success "File /etc/resolv.conf dikonfigurasi"
    
    # Lock file agar tidak berubah
    chattr +i /etc/resolv.conf
    print_success "File /etc/resolv.conf dikunci (immutable)"
}

# STEP 3: TEST KONEKSI
test_connectivity() {
    print_header "STEP 3: TEST KONEKSI JARINGAN"
    
    print_info "Testing ping ke Google DNS (8.8.8.8)..."
    if ping -c 3 8.8.8.8 > /dev/null 2>&1; then
        print_success "Koneksi ke 8.8.8.8 berhasil"
    else
        print_warning "Koneksi ke 8.8.8.8 gagal - periksa konfigurasi jaringan"
    fi
    
    print_info "Testing ping ke google.com..."
    if ping -c 3 google.com > /dev/null 2>&1; then
        print_success "Koneksi ke google.com berhasil"
    else
        print_warning "Koneksi ke google.com gagal - periksa DNS atau koneksi internet"
    fi
}

# STEP 4: SETUP REPOSITORY
setup_repository() {
    print_header "STEP 4: SETUP REPOSITORY DEBIAN"
    
    # Backup sources.list
    if [[ -f /etc/apt/sources.list ]]; then
        cp /etc/apt/sources.list /etc/apt/sources.list.backup
        print_success "Backup sources.list dibuat"
    fi
    
    # Konfigurasi sources.list untuk Debian 11 (Bullseye)
    cat > /etc/apt/sources.list <<EOF
deb http://deb.debian.org/debian bullseye main contrib non-free
deb http://security.debian.org/debian-security bullseye-security main contrib non-free
deb http://deb.debian.org/debian bullseye-updates main contrib non-free
EOF
    
    print_success "File /etc/apt/sources.list dikonfigurasi"
    
    # Update repository
    print_info "Melakukan apt update..."
    if apt update > /dev/null 2>&1; then
        print_success "Repository berhasil diupdate"
    else
        print_error "Gagal update repository - periksa koneksi internet"
        exit 1
    fi
}

# STEP 5: INSTALL BIND9 DAN DNSUTILS
install_dns_packages() {
    print_header "STEP 5: INSTALL BIND9 DAN DNSUTILS"
    
    print_info "Installing bind9 dan dnsutils..."
    apt install -y bind9 dnsutils > /dev/null 2>&1
    
    print_success "Paket bind9 dan dnsutils berhasil diinstall"
}

# STEP 6: KONFIGURASI BIND9 - NAMED.CONF.LOCAL
configure_named_conf_local() {
    print_header "STEP 6: KONFIGURASI NAMED.CONF.LOCAL"
    
    # Backup original file
    if [[ -f /etc/bind/named.conf.local ]]; then
        cp /etc/bind/named.conf.local /etc/bind/named.conf.local.backup
        print_success "Backup named.conf.local dibuat"
    fi
    
    # Ekstrak network ID dari IP (3 oktet pertama untuk /24)
    IP_OCTETS=$(echo $IP_ADDRESS | cut -d'/' -f1 | cut -d'.' -f1-3)
    NETWORK_ID=$(echo $IP_OCTETS | tr '.' ' ' | awk '{print $1"."$2"."$3}')
    REVERSE_ZONE=$(echo $NETWORK_ID | awk -F'.' '{print $3"."$2"."$1".in-addr.arpa"}')
    
    # Buat konfigurasi named.conf.local
    cat >> /etc/bind/named.conf.local <<EOF

// Forward Zone untuk domain
zone "$DOMAIN_NAME" {
    file "/etc/bind/conf_domain";
    type master;
};

// Reverse Zone untuk IP
zone "$REVERSE_ZONE" {
    type master;
    file "/etc/bind/conf_ip";
};
EOF
    
    print_success "File /etc/bind/named.conf.local dikonfigurasi"
    print_info "Forward Zone: $DOMAIN_NAME"
    print_info "Reverse Zone: $REVERSE_ZONE"
}

# STEP 7: BUAT FILE KONFIGURASI DOMAIN (conf_domain)
create_conf_domain() {
    print_header "STEP 7: MEMBUAT FILE KONFIGURASI DOMAIN"
    
    # Masuk ke direktori bind
    cd /etc/bind
    
    # Copy template file
    if [[ -f db.local ]]; then
        cp db.local conf_domain
        print_success "File conf_domain dibuat dari template db.local"
    else
        print_error "Template db.local tidak ditemukan!"
        exit 1
    fi
    
    # Ekstrak IP lokal
    IP_ONLY=$(echo $IP_ADDRESS | cut -d'/' -f1)
    
    # Ubah localhost menjadi domain name dan 127.0.0.1 menjadi IP lokal
    # Menggunakan sed untuk replace dengan escape yang tepat
    sed -i "s/localhost/$DOMAIN_NAME/g" /etc/bind/conf_domain
    sed -i "s/127\.0\.0\.1/$IP_ONLY/g" /etc/bind/conf_domain
    
    print_success "File /etc/bind/conf_domain dikonfigurasi dengan:"
    print_info "  Domain: $DOMAIN_NAME"
    print_info "  IP: $IP_ONLY"
}

# STEP 8: BUAT FILE KONFIGURASI IP (conf_ip)
create_conf_ip() {
    print_header "STEP 8: MEMBUAT FILE KONFIGURASI REVERSE DNS"
    
    cd /etc/bind
    
    # Copy template file
    if [[ -f db.127 ]]; then
        cp db.127 conf_ip
        print_success "File conf_ip dibuat dari template db.127"
    else
        print_error "Template db.127 tidak ditemukan!"
        exit 1
    fi
    
    # Ekstrak host ID (oktet terakhir) dari IP
    IP_ONLY=$(echo $IP_ADDRESS | cut -d'/' -f1)
    HOST_ID=$(echo $IP_ONLY | awk -F'.' '{print $4}')
    
    # Ubah localhost dan host ID
    sed -i "s/localhost/$DOMAIN_NAME/g" /etc/bind/conf_ip
    sed -i "s/1\.0\.0/$HOST_ID/g" /etc/bind/conf_ip
    
    print_success "File /etc/bind/conf_ip dikonfigurasi dengan:"
    print_info "  Domain: $DOMAIN_NAME"
    print_info "  Host ID: $HOST_ID"
}

# STEP 9: RESTART BIND9
restart_bind9() {
    print_header "STEP 9: MENERAPKAN KONFIGURASI BIND9"
    
    print_info "Melakukan systemctl restart bind9..."
    systemctl restart bind9
    
    # Cek status
    if systemctl is-active --quiet bind9; then
        print_success "Service bind9 berhasil direstart dan aktif"
    else
        print_error "Service bind9 gagal distart!"
        systemctl status bind9
        exit 1
    fi
}

# STEP 10: TEST DNS
test_dns() {
    print_header "STEP 10: TEST KONFIGURASI DNS"
    
    print_info "Testing forward DNS lookup ($DOMAIN_NAME)..."
    if nslookup "$DOMAIN_NAME" > /dev/null 2>&1; then
        print_success "Forward DNS lookup berhasil:"
        nslookup "$DOMAIN_NAME"
    else
        print_warning "Forward DNS lookup mengalami masalah"
        nslookup "$DOMAIN_NAME" || true
    fi
    
    echo ""
    
    IP_ONLY=$(echo $IP_ADDRESS | cut -d'/' -f1)
    print_info "Testing reverse DNS lookup ($IP_ONLY)..."
    if nslookup "$IP_ONLY" > /dev/null 2>&1; then
        print_success "Reverse DNS lookup berhasil:"
        nslookup "$IP_ONLY"
    else
        print_warning "Reverse DNS lookup mengalami masalah"
        nslookup "$IP_ONLY" || true
    fi
}

# FUNGSI RINGKASAN KONFIGURASI
show_summary() {
    print_header "RINGKASAN KONFIGURASI"
    
    IP_ONLY=$(echo $IP_ADDRESS | cut -d'/' -f1)
    IP_OCTETS=$(echo $IP_ONLY | cut -d'.' -f1-3)
    HOST_ID=$(echo $IP_ONLY | awk -F'.' '{print $4}')
    REVERSE_ZONE=$(echo $IP_OCTETS | awk -F'.' '{print $3"."$2"."$1".in-addr.arpa"}')
    
    echo "Interface Jaringan    : $INTERFACE"
    echo "IP Address           : $IP_ADDRESS"
    echo "Gateway              : $GATEWAY"
    echo "Domain Name          : $DOMAIN_NAME"
    echo "Nameserver Local     : $IP_ONLY"
    echo "Nameserver Forwarder : $NAMESERVER_FORWARD"
    echo ""
    echo "Reverse Zone         : $REVERSE_ZONE"
    echo "Host ID              : $HOST_ID"
    echo ""
    print_success "Konfigurasi Selesai!"
    echo ""
    echo "File Backup yang dibuat:"
    echo "  - /etc/network/interfaces.backup"
    echo "  - /etc/resolv.conf.backup"
    echo "  - /etc/apt/sources.list.backup"
    echo "  - /etc/bind/named.conf.local.backup"
}

# FUNGSI ROLLBACK
show_rollback_instructions() {
    echo ""
    print_warning "JIKA TERJADI ERROR, GUNAKAN PERINTAH BERIKUT UNTUK ROLLBACK:"
    echo ""
    echo "# Rollback networking"
    echo "sudo cp /etc/network/interfaces.backup /etc/network/interfaces"
    echo "sudo systemctl restart networking"
    echo ""
    echo "# Rollback DNS"
    echo "sudo chattr -i /etc/resolv.conf  # Unlock file terlebih dahulu"
    echo "sudo cp /etc/resolv.conf.backup /etc/resolv.conf"
    echo ""
    echo "# Rollback repository"
    echo "sudo cp /etc/apt/sources.list.backup /etc/apt/sources.list"
    echo "sudo apt update"
    echo ""
    echo "# Rollback BIND9"
    echo "sudo cp /etc/bind/named.conf.local.backup /etc/bind/named.conf.local"
    echo "sudo systemctl restart bind9"
}

# MAIN PROGRAM
main() {
    clear
    
    # Banner
    echo -e "${BLUE}"
    cat << "EOF"
╔════════════════════════════════════════════════════════╗
║  OTOMASI KONFIGURASI DEBIAN 11 (IP - DNS)             ║
║  Berdasarkan Modul UJIKOM                              ║
╚════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    # Check root
    check_root
    
    # Gather configuration
    print_header "INPUT KONFIGURASI"
    get_network_interface
    get_ip_config
    get_dns_config
    
    # Show configuration summary
    echo ""
    print_info "Konfigurasi yang akan diterapkan:"
    echo "  Interface    : $INTERFACE"
    echo "  IP Address   : $IP_ADDRESS"
    echo "  Gateway      : $GATEWAY"
    echo "  Domain       : $DOMAIN_NAME"
    echo "  Nameserver   : $NAMESERVER_LOCAL, $NAMESERVER_FORWARD"
    echo ""
    
    read -p "Lanjutkan konfigurasi? (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Konfigurasi dibatalkan"
        exit 0
    fi
    
    # Execute configuration steps
    configure_ip_address
    configure_resolv_conf
    test_connectivity
    setup_repository
    install_dns_packages
    configure_named_conf_local
    create_conf_domain
    create_conf_ip
    restart_bind9
    test_dns
    
    # Show summary
    show_summary
    show_rollback_instructions
}

# Run main program
main "$@"
