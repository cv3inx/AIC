# AIC - Android in Cloud (Redroid Tools) 🚀

Script instalasi otomatis untuk **Redroid (Android in Docker)** yang dioptimalkan untuk koneksi dari HP Android. Dilengkapi dengan anti-disconnect, device spoofing, dan auto-install APK.

## 📱 Fitur Utama

| Fitur                   | Deskripsi                                         |
| ----------------------- | ------------------------------------------------- |
| 🔄 Auto Device Spoofing | 200+ database device (Samsung, Xiaomi, OPPO, dll) |
| 📡 Anti-Disconnect      | Host-mode networking untuk koneksi stabil         |
| �️ Anti-Detect           | Fingerprint & IMEI random                         |
| ⚡ Auto Setup           | Kernel binder/ashmem otomatis                     |
| 📲 Auto Install APK     | Otomatis install Duku Live                        |

## 🛠️ Persyaratan

- VPS Ubuntu/Debian (Fresh)
- Minimal 2GB RAM
- Akses root (`sudo su`)

---

## 📥 Cara Install & Run

### 1️⃣ TUYUL Mode (200+ Device, Random Identity)

Script lengkap dengan 200+ database device, anti-detect, dan auto-config.

```bash
wget https://raw.githubusercontent.com/cv3inx/AIC/main/tuyul.sh && chmod +x tuyul.sh && ./tuyul.sh
```

### 2️⃣ GEN Mode (Standard Generator)

Generator standar dengan database device dan auto-install.

```bash
wget https://raw.githubusercontent.com/cv3inx/AIC/main/gen.sh && chmod +x gen.sh && ./gen.sh
```

### 3️⃣ HOST Mode (Realme Narzo, Anti-Disconnect)

Mode host networking untuk koneksi paling stabil.

```bash
wget https://raw.githubusercontent.com/cv3inx/AIC/main/install.sh && chmod +x install.sh && ./install.sh
```

---

## 📋 Perbandingan Mode

| Mode      | Device       | Networking | Use Case               |
| --------- | ------------ | ---------- | ---------------------- |
| **TUYUL** | 200+ Random  | Bridge     | Multi-account, farming |
| **GEN**   | 200+ Random  | Bridge     | General purpose        |
| **HOST**  | Realme Narzo | Host       | Koneksi paling stabil  |

---

## ⚙️ Spesifikasi Default

- **Resolution:** 720x1280 (HD)
- **DPI:** 320
- **Android:** 8.1 / 11 (tergantung mode)
- **ADB Port:** 5555
- **Security:** ADB Secure Disabled

## 🔧 Perintah Berguna

```bash
# Cek status container
docker ps

# Restart container
docker restart android_11

# Hapus container
docker rm -f android_11

# Reset database device (TUYUL/GEN)
rm /root/.used_devices

# Connect ADB
adb connect localhost:5555
```

## 📝 License

MIT License - Free to use and modify.
