# Otomasi Konfigurasi Debian 11 (IP - DNS)

Script bash otomasi lengkap untuk konfigurasi Debian 11 berdasarkan modul UJIKOM, mencakup:
- Konfigurasi IP Address
- Konfigurasi DNS Resolver
- Setup Repository Debian
- Instalasi dan konfigurasi BIND9 DNS Server
- Reverse DNS Configuration

## 📋 Daftar Isi

- [Requirements](#requirements)
- [Instalasi](#instalasi)
- [Penggunaan](#penggunaan)
- [Fitur](#fitur)
- [Struktur Konfigurasi](#struktur-konfigurasi)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Rollback](#rollback)

## 🔧 Requirements

- **OS**: Debian 11 (Bullseye)
- **Akses**: Root atau sudo privileges
- **Tools**: bash, curl (optional untuk download)
- **Network**: Interface jaringan yang terkonfigurasi

## 📥 Instalasi

### Opsi 1: Download dari GitHub

```bash
# Clone repository
git clone https://github.com/username/debian-config-automation.git
cd debian-config-automation

# Berikan permission execute
chmod +x debian-config-automation.sh
```

### Opsi 2: Direct Download

```bash
# Download script langsung
curl -O https://raw.githubusercontent.com/username/debian-config-automation/main/debian-config-automation.sh

# Atau menggunakan wget
wget https://raw.githubusercontent.com/username/debian-config-automation/main/debian-config-automation.sh

# Berikan permission execute
chmod +x debian-config-automation.sh
```

### Opsi 3: Copy Manual

Copy file `debian-config-automation.sh` ke sistem Debian Anda dan jalankan:

```bash
chmod +x debian-config-automation.sh
```

## 🚀 Penggunaan

### Cara Menjalankan Script

```bash
# Gunakan sudo
sudo bash debian-config-automation.sh

# Atau jika sudah login sebagai root
./debian-config-automation.sh
```

### Input yang Diminta

Script akan secara interaktif meminta input berikut:

1. **Network Interface**
   - Contoh: `enp2s0`, `eth0`, `wlan0`
   - Script menampilkan daftar interface yang tersedia

2. **IP Address dengan CIDR**
   - Contoh: `192.168.100.11/24`
   - Format: `XXX.XXX.XXX.XXX/XX`

3. **Gateway**
   - Contoh: `192.168.100.1`
   - Router/gateway jaringan Anda

4. **Domain Name**
   - Contoh: `tkjsmkdt.org`
   - Domain lokal untuk DNS server

5. **Nameserver Local**
   - Contoh: `192.168.100.11`
   - IP dari server DNS ini

6. **Nameserver Forwarder**
   - Contoh: `8.8.8.8`
   - DNS public untuk forward query

### Contoh Sesi

```bash
$ sudo bash debian-config-automation.sh

╔════════════════════════════════════════════════════════╗
║  OTOMASI KONFIGURASI DEBIAN 11 (IP - DNS)             ║
║  Berdasarkan Modul UJIKOM                              ║
╚════════════════════════════════════════════════════════╝

========================================
INPUT KONFIGURASI
========================================

ℹ Daftar interface jaringan yang tersedia:
lo
enp2s0

Masukkan nama interface (misal: enp2s0, eth0): enp2s0
✓ Interface dipilih: enp2s0

Masukkan IP address dengan CIDR (misal: 192.168.100.11/24): 192.168.100.11/24
✓ IP Address: 192.168.100.11/24

Masukkan Gateway (misal: 192.168.100.1): 192.168.100.1
✓ Gateway: 192.168.100.1

Masukkan nama domain (misal: tkjsmkdt.org): tkjsmkdt.org
✓ Domain Name: tkjsmkdt.org

Masukkan nameserver local (misal: 192.168.100.11): 192.168.100.11
✓ Nameserver Local: 192.168.100.11

Masukkan nameserver forwarder (misal: 8.8.8.8): 8.8.8.8
✓ Nameserver Forwarder: 8.8.8.8

ℹ Konfigurasi yang akan diterapkan:
  Interface    : enp2s0
  IP Address   : 192.168.100.11/24
  Gateway      : 192.168.100.1
  Domain       : tkjsmkdt.org
  Nameserver   : 192.168.100.11, 8.8.8.8

Lanjutkan konfigurasi? (y/n): y

[Script akan melanjutkan dengan konfigurasi...]
```

## ✨ Fitur

### Konfigurasi Jaringan
- ✅ Otomatis deteksi dan konfigurasi interface jaringan
- ✅ Setting IP static dengan gateway
- ✅ Konfigurasi DNS resolver dengan lock immutable
- ✅ Test koneksi internet (ping 8.8.8.8 dan google.com)

### Manajemen Repository
- ✅ Backup otomatis sources.list sebelum modifikasi
- ✅ Konfigurasi repository resmi Debian Bullseye
- ✅ Validasi hasil apt update

### DNS Server (BIND9)
- ✅ Instalasi bind9 dan dnsutils otomatis
- ✅ Konfigurasi forward zone (domain)
- ✅ Konfigurasi reverse zone (IP)
- ✅ Otomatis extract network ID dan reverse zone dari IP
- ✅ Template-based configuration dari system files
- ✅ Service restart dan validation

### Error Handling & Backup
- ✅ Backup semua file original sebelum modifikasi
- ✅ Validasi input dengan regex
- ✅ Error handling di setiap step
- ✅ Pesan error yang jelas dan actionable
- ✅ Instruksi rollback otomatis

### Output & Reporting
- ✅ Color-coded output untuk readability
- ✅ Progress indicator untuk setiap step
- ✅ Summary konfigurasi di akhir
- ✅ Instruksi manual testing tersedia

## 📁 Struktur Konfigurasi

### File yang Dimodifikasi

```
/etc/network/interfaces          → Konfigurasi IP static
/etc/resolv.conf                 → DNS resolver (locked immutable)
/etc/apt/sources.list            → Repository debian
/etc/bind/named.conf.local       → Konfigurasi zona BIND9
/etc/bind/conf_domain            → Forward zone file (copy dari db.local)
/etc/bind/conf_ip                → Reverse zone file (copy dari db.127)
```

### File Backup yang Dibuat

```
/etc/network/interfaces.backup
/etc/resolv.conf.backup
/etc/apt/sources.list.backup
/etc/bind/named.conf.local.backup
```

## 🧪 Testing

### Test Koneksi Jaringan

```bash
# Test koneksi ke Google DNS
ping -c 3 8.8.8.8

# Test DNS resolution
ping -c 3 google.com
```

### Test DNS Server (Forward Lookup)

```bash
# Test domain resolution
nslookup tkjsmkdt.org

# Output yang diharapkan:
# Server:         192.168.100.11
# Address:        192.168.100.11#53
# 
# Name:   tkjsmkdt.org
# Address: 192.168.100.11
```

### Test Reverse DNS

```bash
# Test reverse lookup
nslookup 192.168.100.11

# Output yang diharapkan:
# Server:         192.168.100.11
# Address:        192.168.100.11#53
# 
# 11.100.168.192.in-addr.arpa    name = tkjsmkdt.org.
```

### Test Resolv.conf

```bash
# Cek isi resolv.conf
cat /etc/resolv.conf

# Cek immutable flag
lsattr /etc/resolv.conf
```

### Test Bind9 Service

```bash
# Cek status service
systemctl status bind9

# Cek listening ports
netstat -tulpn | grep bind9
# atau
ss -tulpn | grep 53

# Cek log bind9
journalctl -u bind9 -n 50
# atau
tail -f /var/log/syslog | grep named
```

## 🔍 Troubleshooting

### Masalah: "Koneksi ke 8.8.8.8 gagal"

**Kemungkinan Penyebab:**
- Network interface tidak naik (up)
- Gateway tidak reachable
- Firewall blocking ICMP

**Solusi:**
```bash
# Check interface status
ip link show enp2s0

# Check routing table
ip route

# Ensure interface is up
sudo ip link set enp2s0 up

# Restart networking
sudo systemctl restart networking
```

### Masalah: "Service bind9 gagal distart"

**Kemungkinan Penyebab:**
- Syntax error di config file
- Port 53 sudah digunakan
- Permission issues

**Solusi:**
```bash
# Check config syntax
sudo named-checkconf /etc/bind/named.conf

# Check zone file syntax
sudo named-checkzone tkjsmkdt.org /etc/bind/conf_domain
sudo named-checkzone 100.168.192.in-addr.arpa /etc/bind/conf_ip

# Check port usage
sudo netstat -tulpn | grep 53

# Lihat detailed error
sudo systemctl status bind9 -l
```

### Masalah: "DNS resolution tidak bekerja"

**Kemungkinan Penyebab:**
- Zone file tidak di-load dengan benar
- Ownership/permission zone files salah
- Forwarder tidak responsif

**Solusi:**
```bash
# Fix file ownership
sudo chown bind:bind /etc/bind/conf_domain
sudo chown bind:bind /etc/bind/conf_ip
sudo chmod 644 /etc/bind/conf_*

# Check if zone loaded
sudo named-checkzone tkjsmkdt.org /etc/bind/conf_domain

# View bind logs
sudo tail -f /var/log/syslog | grep named

# Restart bind9
sudo systemctl restart bind9
```

### Masalah: "Tidak bisa unlock /etc/resolv.conf"

```bash
# Lihat immutable flag
lsattr /etc/resolv.conf

# Remove immutable flag
sudo chattr -i /etc/resolv.conf

# Sekarang bisa diedit
sudo nano /etc/resolv.conf

# Lock kembali jika diperlukan
sudo chattr +i /etc/resolv.conf
```

## 🔄 Rollback

Jika ada masalah, gunakan instruksi rollback berikut:

### Rollback Networking

```bash
sudo cp /etc/network/interfaces.backup /etc/network/interfaces
sudo systemctl restart networking
```

### Rollback DNS Resolver

```bash
# Unlock file terlebih dahulu
sudo chattr -i /etc/resolv.conf

# Restore dari backup
sudo cp /etc/resolv.conf.backup /etc/resolv.conf

# Lock kembali
sudo chattr +i /etc/resolv.conf
```

### Rollback Repository

```bash
sudo cp /etc/apt/sources.list.backup /etc/apt/sources.list
sudo apt update
```

### Rollback BIND9

```bash
# Stop service
sudo systemctl stop bind9

# Restore config
sudo cp /etc/bind/named.conf.local.backup /etc/bind/named.conf.local

# Remove zone files jika dibuat manual
sudo rm /etc/bind/conf_domain /etc/bind/conf_ip

# Start service
sudo systemctl start bind9
```

### Rollback Semua (Full Reset)

```bash
# Execute all rollbacks
sudo cp /etc/network/interfaces.backup /etc/network/interfaces
sudo systemctl restart networking

sudo chattr -i /etc/resolv.conf 2>/dev/null || true
sudo cp /etc/resolv.conf.backup /etc/resolv.conf
sudo chattr +i /etc/resolv.conf

sudo cp /etc/apt/sources.list.backup /etc/apt/sources.list
sudo apt update

sudo systemctl stop bind9
sudo cp /etc/bind/named.conf.local.backup /etc/bind/named.conf.local
sudo rm /etc/bind/conf_domain /etc/bind/conf_ip
sudo systemctl start bind9

echo "Rollback completed!"
```

## 📊 Sesuai dengan Modul UJIKOM

Script ini mengimplementasikan semua langkah dari modul UJIKOM:

### ✅ Step 1: Installasi Debian
- Deteksi environment Debian yang sudah ada

### ✅ Step 2: Setting IP Address
- Deteksi interface otomatis
- Input IP dengan validasi CIDR
- Modifikasi `/etc/network/interfaces`
- Restart networking service
- Konfigurasi `/etc/resolv.conf`
- Lock file dengan `chattr +i`
- Test koneksi dengan ping

### ✅ Step 3: Setting Repository
- Backup `sources.list` original
- Konfigurasi repository resmi Debian
- Validasi dengan `apt update`

### ✅ Step 4: Setting DNS Server
- Install bind9 dan dnsutils
- Konfigurasi forward zone di `named.conf.local`
- Konfigurasi reverse zone
- Copy template files (db.local, db.127)
- Modifikasi zone files sesuai spesifikasi
- Restart bind9 service
- Test dengan nslookup (forward dan reverse)

## 📝 Lisensi

Script ini dibuat berdasarkan modul UJIKOM untuk keperluan edukasi.

## 🤝 Kontribusi

Silakan buat issue atau pull request untuk improvement:
1. Fork repository
2. Buat feature branch (`git checkout -b feature/improvement`)
3. Commit changes (`git commit -am 'Add improvement'`)
4. Push ke branch (`git push origin feature/improvement`)
5. Buat Pull Request

## 📧 Support

Jika ada pertanyaan atau masalah:
- Buka issue di GitHub
- Sertakan output lengkap dari script
- Sertakan informasi: Debian version, network setup, error message

## 🎓 Catatan Pendidikan

Script ini dirancang untuk tujuan pembelajaran dan dapat digunakan untuk:
- Lab praktik UJIKOM
- Pembelajaran konfigurasi Linux
- Server setup automation
- Infrastructure as Code (IaC) practice

**Disclaimer**: Gunakan dengan hati-hati di production environment. Selalu test di staging terlebih dahulu dan backup data penting.

---

**Last Updated**: 2024
**Tested on**: Debian 11 (Bullseye)
