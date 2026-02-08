#!/bin/bash

echo "=============================================="
echo ">>> AUTO INSTALL: REALME NARZO (HOST MODE)"
echo ">>> Include: Setup Kernel & Fresh Install VPS"
echo "=============================================="

if [ "$EUID" -ne 0 ]; then 
  echo "Tolong jalankan sebagai root (sudo su)"
  exit
fi

# ==========================================================
# 1. SETUP INSTALL VPS FRESH (DOCKER & DEPENDENCIES)
# ==========================================================
echo ">>> [SETUP] Update & Install Dependencies..."
apt-get update -y
# Install Docker & ADB jika belum ada
apt-get install -y docker.io android-tools-adb curl kmod

# Pastikan Docker Service jalan
systemctl start docker
systemctl enable docker

# ==========================================================
# 2. SETUP KERNEL (WAJIB UNTUK REDROID)
# ==========================================================
echo ">>> [KERNEL] Memuat modul binder & ashmem..."
# Load modules
modprobe binder_linux devices="binder,hwbinder,vndbinder" 2>/dev/null
modprobe ashmem_linux 2>/dev/null

# Setup BinderFS
mkdir -p /dev/binderfs
mount -t binder binder /dev/binderfs 2>/dev/null
chmod 777 /dev/binderfs/*

# Setup Ashmem (Membuat node jika tidak ada)
if [ ! -e /dev/ashmem ]; then
    mknod /dev/ashmem c 10 61
    chmod 777 /dev/ashmem
fi

# ==========================================================
# 3. LOGIKA UTAMA (Sesuai Permintaan Anda)
# ==========================================================

# MATIKAN ADB SERVER BAWAAN VPS (WAJIB!)
echo ">>> [KILL] Mematikan ADB Server host..."
adb kill-server > /dev/null 2>&1
killall adb > /dev/null 2>&1
killall adbd > /dev/null 2>&1

# BERSIHKAN CONTAINER
echo ">>> [CLEAN] Hapus container lama..."
sudo docker rm -f android_8 > /dev/null 2>&1
sudo rm -rf ~/data_8 && mkdir -p ~/data_8

# DATABASE IDENTITAS (Tetap Realme Narzo 60x)
DEVICES=("realme|realme|RMX3782|RMX3782|realme/RMX3782/RMX3782:13/TP1A.220905.001/1693393955:user/release-keys")
IFS='|' read -r BRAND MANUF MODEL DEV_NAME FINGERPRINT <<< "${DEVICES[0]}"

GEN_IMEI=$(shuf -i 860000000000000-869999999999999 -n 1)
GEN_PHONE="+628$(shuf -i 100000000-999999999 -n 1)"

# JALANKAN DENGAN --net=host
echo ">>> [START] Menjalankan Android 8 (Host Mode)..."

sudo docker run -itd \
    --net=host \
    --cpus="3" \
    --memory="12288m" \
    --memory-swap="-1" \
    --privileged \
    --restart=always \
    -v ~/data_8:/data \
    --name android_8 \
    redroid/redroid:8.1.0-latest \
    androidboot.redroid_width=720 \
    androidboot.redroid_height=1280 \
    androidboot.redroid_dpi=320 \
    androidboot.redroid_fps=30 \
    androidboot.redroid_gpu_mode=guest \
    androidboot.serialno=$(cat /dev/urandom | tr -dc 'A-Z0-9' | fold -w 10 | head -n 1) \
    ro.product.brand="$BRAND" \
    ro.product.manufacturer="$MANUF" \
    ro.product.model="$MODEL" \
    ro.product.device="$DEV_NAME" \
    ro.build.fingerprint="$FINGERPRINT" \
    ro.ril.oem.imei="$GEN_IMEI" \
    ro.ril.oem.phone_number="$GEN_PHONE" \
    gsm.sim.msisdn="$GEN_PHONE" \
    ro.adb.secure=0 \
    ro.secure=0 \
    ro.debuggable=1 > /dev/null

if [ $? -eq 0 ]; then
    echo ">>> [SUKSES] Container berjalan di Host Network!"
else
    echo ">>> [ERROR] Gagal. Pastikan port 5555 kosong."
    exit 1
fi

echo ">>> [WAIT] Menunggu booting 10 detik..."
sleep 10

# KONEKSI ADB (DARI DALAM)
echo ">>> [SETUP] Mengatur sinyal..."
docker exec android_8 setprop gsm.sim.operator.alpha "Telkomsel"
docker exec android_8 setprop gsm.sim.operator.numeric "51010"
docker exec android_8 setprop gsm.sim.msisdn "$GEN_PHONE"

echo "=============================================="
echo ">>> SIAP DIHUBUNGKAN!"
echo ">>> IP VPS: $(curl -s ifconfig.me)"
echo ">>> Port  : 5555"
echo "=============================================="
echo "PENTING: Jangan jalankan perintah 'adb connect' di terminal VPS ini lagi."
echo "Langsung saja connect dari aplikasi EasyControl di HP/PC kamu."
