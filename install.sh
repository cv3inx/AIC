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
# 1. SMART DEPENDENCY CHECK & INSTALL
# ==========================================================
echo ">>> [CHECK] Memeriksa dependencies..."

# Fungsi cek command
check_cmd() {
    command -v "$1" &> /dev/null
}

NEED_UPDATE=false
MISSING_PKGS=()

# Cek Docker
if check_cmd docker; then
    echo "   ✓ Docker sudah terinstall ($(docker --version | cut -d' ' -f3 | tr -d ','))"
else
    echo "   ✗ Docker belum terinstall"
    MISSING_PKGS+=("docker.io")
    NEED_UPDATE=true
fi

# Cek ADB  
if check_cmd adb; then
    echo "   ✓ ADB sudah terinstall ($(adb version | head -1 | cut -d' ' -f5))"
else
    echo "   ✗ ADB belum terinstall"
    MISSING_PKGS+=("android-tools-adb")
    NEED_UPDATE=true
fi

# Cek curl
if check_cmd curl; then
    echo "   ✓ Curl sudah terinstall"
else
    echo "   ✗ Curl belum terinstall"
    MISSING_PKGS+=("curl")
    NEED_UPDATE=true
fi

# Cek kmod (modprobe)
if check_cmd modprobe; then
    echo "   ✓ Kmod sudah terinstall"
else
    echo "   ✗ Kmod belum terinstall"
    MISSING_PKGS+=("kmod")
    NEED_UPDATE=true
fi

# Cek shuf (coreutils)
if check_cmd shuf; then
    echo "   ✓ Coreutils sudah terinstall"
else
    echo "   ✗ Coreutils belum terinstall"
    MISSING_PKGS+=("coreutils")
    NEED_UPDATE=true
fi

# Install jika ada yang missing
if [ "$NEED_UPDATE" = true ]; then
    echo ""
    echo ">>> [INSTALL] Menginstall: ${MISSING_PKGS[*]}..."
    apt-get update -y > /dev/null 2>&1
    apt-get install -y "${MISSING_PKGS[@]}" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo ">>> [OK] Dependencies berhasil diinstall!"
    else
        echo ">>> [ERROR] Gagal install dependencies!"
        exit 1
    fi
else
    echo ""
    echo ">>> [SKIP] Semua dependencies sudah terinstall!"
fi

# Pastikan Docker Service jalan
if ! systemctl is-active --quiet docker; then
    echo ">>> [START] Menjalankan Docker service..."
    systemctl start docker
    systemctl enable docker > /dev/null 2>&1
else
    echo ">>> [OK] Docker service sudah berjalan"
fi


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

# ==========================================================
# REAL DEVICE TAC DATABASE (8 digit pertama IMEI)
# Format: TAC|Brand|Model
# ==========================================================
TAC_DATABASE=(
    # Samsung Galaxy S Series
    "35332510|Samsung|Galaxy S23 Ultra"
    "35332511|Samsung|Galaxy S23+"
    "35332512|Samsung|Galaxy S23"
    "35290611|Samsung|Galaxy S22 Ultra"
    "35290612|Samsung|Galaxy S22+"
    "35290613|Samsung|Galaxy S22"
    "35260010|Samsung|Galaxy S21 Ultra"
    "35260011|Samsung|Galaxy S21+"
    "35260012|Samsung|Galaxy S21"
    # Samsung Galaxy A Series
    "35456710|Samsung|Galaxy A54"
    "35456711|Samsung|Galaxy A34"
    "35433010|Samsung|Galaxy A53"
    "35433011|Samsung|Galaxy A33"
    "35350410|Samsung|Galaxy A52"
    # Xiaomi
    "86769804|Xiaomi|13 Pro"
    "86769805|Xiaomi|13"
    "86754303|Xiaomi|12 Pro"
    "86754304|Xiaomi|12"
    "86738902|Xiaomi|11T Pro"
    "86738903|Xiaomi|11T"
    "86720001|Xiaomi|Mi 11"
    # Redmi
    "86769901|Redmi|Note 12 Pro"
    "86769902|Redmi|Note 12"
    "86754401|Redmi|Note 11 Pro"
    "86754402|Redmi|Note 11"
    "86738801|Redmi|Note 10 Pro"
    "86738802|Redmi|Note 10"
    # POCO
    "86769801|POCO|F5 Pro"
    "86769802|POCO|F5"
    "86754201|POCO|X4 Pro"
    "86738701|POCO|X3 Pro"
    # OPPO
    "86467502|OPPO|Reno 9 Pro"
    "86467503|OPPO|Reno 8 Pro"
    "86452101|OPPO|Reno 7"
    "86436701|OPPO|Reno 6"
    "86421301|OPPO|Find X5 Pro"
    # Realme
    "86467601|Realme|GT 3"
    "86467602|Realme|GT Neo 5"
    "86452201|Realme|GT 2 Pro"
    "86436801|Realme|9 Pro+"
    "86421401|Realme|8 Pro"
    # Vivo
    "86467701|Vivo|X90 Pro"
    "86467702|Vivo|X80 Pro"
    "86452301|Vivo|V27 Pro"
    "86436901|Vivo|V25 Pro"
    # Infinix
    "35890001|Infinix|Note 30"
    "35890002|Infinix|Hot 30"
    # OnePlus
    "86857001|OnePlus|11"
    "86857002|OnePlus|10 Pro"
    "86842501|OnePlus|9 Pro"
)

# Fungsi Luhn checksum untuk IMEI valid
calculate_luhn() {
    local imei_14="$1"
    local sum=0
    local digit
    for i in {0..13}; do
        digit=${imei_14:$i:1}
        if [ $((i % 2)) -eq 1 ]; then
            digit=$((digit * 2))
            if [ $digit -gt 9 ]; then
                digit=$((digit - 9))
            fi
        fi
        sum=$((sum + digit))
    done
    echo $(( (10 - (sum % 10)) % 10 ))
}

# Pilih TAC random dari database
RANDOM_TAC_INDEX=$((RANDOM % ${#TAC_DATABASE[@]}))
TAC_ENTRY="${TAC_DATABASE[$RANDOM_TAC_INDEX]}"
IFS='|' read -r SELECTED_TAC TAC_BRAND TAC_MODEL <<< "$TAC_ENTRY"

# Generate 6 digit random untuk Serial Number
SERIAL=$(shuf -i 100000-999999 -n 1)

# Gabungkan TAC + Serial (14 digit)
IMEI_14="${SELECTED_TAC}${SERIAL}"

# Hitung checksum Luhn
CHECKSUM=$(calculate_luhn "$IMEI_14")

# IMEI final 15 digit
GEN_IMEI="${IMEI_14}${CHECKSUM}"

echo ">>> [IMEI] Generated from: $TAC_BRAND $TAC_MODEL"
echo ">>> [IMEI] TAC: $SELECTED_TAC | IMEI: $GEN_IMEI"

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

# ==========================================================
# 4. SMART BOOT DETECTION
# ==========================================================
echo ">>> [BOOT] Mendeteksi status booting Android..."

MAX_WAIT=120  # Maksimal tunggu 120 detik
WAIT_COUNT=0
BOOT_COMPLETE=false

while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
    # Cek apakah container running
    CONTAINER_STATUS=$(docker inspect -f '{{.State.Running}}' android_8 2>/dev/null)
    if [ "$CONTAINER_STATUS" != "true" ]; then
        echo "   ⏳ Container belum running... ($WAIT_COUNT detik)"
        sleep 2
        WAIT_COUNT=$((WAIT_COUNT + 2))
        continue
    fi
    
    # Cek boot_completed property
    BOOT_STATUS=$(docker exec android_8 getprop sys.boot_completed 2>/dev/null)
    if [ "$BOOT_STATUS" == "1" ]; then
        BOOT_COMPLETE=true
        echo ""
        echo ">>> [OK] ✓ Android sudah selesai booting! (${WAIT_COUNT} detik)"
        break
    fi
    
    # Progress indicator
    if [ $((WAIT_COUNT % 10)) -eq 0 ]; then
        echo "   ⏳ Menunggu boot... ($WAIT_COUNT detik)"
    fi
    
    sleep 2
    WAIT_COUNT=$((WAIT_COUNT + 2))
done

# Cek timeout
if [ "$BOOT_COMPLETE" != true ]; then
    echo ""
    echo ">>> [WARNING] Boot timeout setelah ${MAX_WAIT} detik"
    echo ">>> [INFO] Melanjutkan dengan setup (mungkin perlu waktu tambahan)..."
fi

# Tunggu sebentar untuk stabilitas
sleep 3

# SETUP SINYAL (DARI DALAM CONTAINER)
echo ">>> [SETUP] Mengatur sinyal operator..."
docker exec android_8 setprop gsm.sim.operator.alpha "Telkomsel"
docker exec android_8 setprop gsm.sim.operator.numeric "51010"
docker exec android_8 setprop gsm.sim.state "READY"
docker exec android_8 setprop gsm.sim.msisdn "$GEN_PHONE"
docker exec android_8 setprop gsm.current.phone-number "$GEN_PHONE"
docker exec android_8 setprop line1.number "$GEN_PHONE"

echo "=============================================="
echo ">>> SIAP DIHUBUNGKAN!"
echo ">>> IP VPS: $(curl -s ifconfig.me)"
echo ">>> Port  : 5555"
echo "=============================================="
echo "PENTING: Jangan jalankan perintah 'adb connect' di terminal VPS ini lagi."
echo "Langsung saja connect dari aplikasi EasyControl di HP/PC kamu."
