# Quick Start Guide

## ⚡ Mulai dalam 5 Menit

### 1️⃣ Download Script

```bash
# Clone repository
git clone https://github.com/username/debian-config-automation.git
cd debian-config-automation

# Atau download langsung
wget https://raw.githubusercontent.com/username/debian-config-automation/main/debian-config-automation.sh
chmod +x debian-config-automation.sh
```

### 2️⃣ Jalankan Script

```bash
# Dengan sudo
sudo bash debian-config-automation.sh

# Atau jika sudah root
./debian-config-automation.sh
```

### 3️⃣ Input Data Anda

Script akan meminta:

```
Masukkan nama interface: enp2s0
Masukkan IP address dengan CIDR: 192.168.100.11/24
Masukkan Gateway: 192.168.100.1
Masukkan nama domain: tkjsmkdt.org
Masukkan nameserver local: 192.168.100.11
Masukkan nameserver forwarder: 8.8.8.8
```

### 4️⃣ Confirm Konfigurasi

```
Lanjutkan konfigurasi? (y/n): y
```

### 5️⃣ Tunggu Selesai

Script akan otomatis:
- ✅ Setup IP static
- ✅ Configure DNS resolver
- ✅ Setup repository
- ✅ Install BIND9
- ✅ Configure DNS server
- ✅ Test koneksi & DNS

---

## 🧪 Test Hasil Konfigurasi

### Cek Koneksi Internet

```bash
ping -c 3 8.8.8.8
ping -c 3 google.com
```

**Output yang diharapkan**: `64 bytes... time=XX.Xms`

### Cek IP Address

```bash
ip addr show enp2s0
```

**Output**: Harus menunjukkan IP yang Anda setup (misal: 192.168.100.11)

### Cek DNS Server (Forward)

```bash
nslookup tkjsmkdt.org
```

**Output yang diharapkan**:
```
Server:         192.168.100.11
Address:        192.168.100.11#53

Name:   tkjsmkdt.org
Address: 192.168.100.11
```

### Cek DNS Server (Reverse)

```bash
nslookup 192.168.100.11
```

**Output yang diharapkan**:
```
Server:         192.168.100.11
Address:        192.168.100.11#53

11.100.168.192.in-addr.arpa    name = tkjsmkdt.org.
```

---

## 🆘 Troubleshooting Cepat

### ❌ "Koneksi ke 8.8.8.8 gagal"

**Solusi:**
```bash
# Restart networking
sudo systemctl restart networking

# Cek routing
ip route

# Cek interface naik
ip link show enp2s0
```

### ❌ "DNS tidak resolve"

**Solusi:**
```bash
# Cek BIND9 berjalan
sudo systemctl status bind9

# Cek log
sudo journalctl -u bind9 -n 20

# Test syntax
sudo named-checkzone tkjsmkdt.org /etc/bind/conf_domain
```

### ❌ "Permission denied"

**Solusi:**
```bash
# Gunakan sudo
sudo bash debian-config-automation.sh

# Atau jadi root dulu
su -
bash debian-config-automation.sh
```

### ❌ "Konfigurasi salah, mau reset"

**Solusi - Rollback semua:**
```bash
# Rollback networking
sudo cp /etc/network/interfaces.backup /etc/network/interfaces
sudo systemctl restart networking

# Rollback DNS
sudo chattr -i /etc/resolv.conf
sudo cp /etc/resolv.conf.backup /etc/resolv.conf
sudo chattr +i /etc/resolv.conf

# Rollback repository
sudo cp /etc/apt/sources.list.backup /etc/apt/sources.list

# Rollback BIND9
sudo systemctl stop bind9
sudo cp /etc/bind/named.conf.local.backup /etc/bind/named.conf.local
sudo rm /etc/bind/conf_domain /etc/bind/conf_ip
sudo systemctl start bind9
```

---

## 📋 Checklist Konfigurasi

Setelah menjalankan script, verifikasi:

- [ ] IP static terset dengan benar
- [ ] Gateway bisa di-ping
- [ ] DNS resolver menunjuk ke server DNS lokal
- [ ] BIND9 service aktif
- [ ] Forward DNS lookup berhasil (nslookup tkjsmkdt.org)
- [ ] Reverse DNS lookup berhasil (nslookup 192.168.100.11)
- [ ] Forwarder DNS berfungsi (nslookup google.com)

---

## 💡 Tips & Tricks

### Jalankan Ulang Bagian Tertentu

Jika hanya ingin mengonfigurasi DNS saja:

```bash
# Manual configure BIND9 saja
sudo apt install -y bind9 dnsutils
sudo nano /etc/bind/named.conf.local
# ... configure manually
sudo systemctl restart bind9
```

### View Log Installation

```bash
# Lihat semua yang terjadi
sudo journalctl -xe -n 100

# Atau cek system log
sudo tail -f /var/log/syslog | grep -E "named|systemctl|networking"
```

### Ubah Konfigurasi Setelah Setup

#### Ubah IP Address

```bash
# Edit file interfaces
sudo nano /etc/network/interfaces

# Update resolv.conf
sudo chattr -i /etc/resolv.conf
sudo nano /etc/resolv.conf
sudo chattr +i /etc/resolv.conf

# Restart
sudo systemctl restart networking
```

#### Ubah Domain DNS

```bash
# Edit zone files
sudo nano /etc/bind/conf_domain
sudo nano /etc/bind/conf_ip

# Edit named.conf.local
sudo nano /etc/bind/named.conf.local

# Restart BIND9
sudo systemctl restart bind9
```

### Backup Custom

```bash
# Backup semua konfigurasi ke folder
mkdir ~/dns-backup
cp -r /etc/bind ~/dns-backup/
cp /etc/network/interfaces ~/dns-backup/
cp /etc/resolv.conf ~/dns-backup/
cp /etc/apt/sources.list ~/dns-backup/

# Archive
tar czf dns-config-backup-$(date +%Y%m%d).tar.gz ~/dns-backup/
```

---

## 🎓 Next Steps

Setelah konfigurasi selesai, Anda bisa:

1. **Tambah Host Records**
   ```bash
   # Edit /etc/bind/conf_domain
   # Tambahkan:
   # www    IN  A   192.168.100.20
   # mail   IN  A   192.168.100.30
   ```

2. **Setup Secondary DNS**
   ```bash
   # Setup slave DNS di server lain
   # Pointing ke primary di 192.168.100.11
   ```

3. **Enable DNSSEC**
   ```bash
   # Untuk security tingkat lanjut
   dnssec-keygen -a RSASHA256 -b 2048 -n ZONE tkjsmkdt.org
   ```

4. **Monitor DNS**
   ```bash
   # Install monitoring tool
   sudo apt install -y dnswatch
   dnswatch -s 192.168.100.11
   ```

---

## 📞 Bantuan Lebih Lanjut

- 📖 Lihat **[README.md](README.md)** untuk dokumentasi lengkap
- 🔧 Lihat **[ADVANCED.md](ADVANCED.md)** untuk customization
- 🐛 Lihat bagian Troubleshooting di README untuk error handling

---

**Siap dimulai? Run:** `sudo bash debian-config-automation.sh`
