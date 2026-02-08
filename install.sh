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
# REAL DEVICE TAC - ONLINE SCRAPING + FALLBACK
# ==========================================================
TAC_CACHE="/tmp/tac_database.txt"
# Multiple sources untuk reliability
TAC_URLS=(
    "https://raw.githubusercontent.com/VTSTech/IMEIDB/main/imeidb.csv"
    "https://raw.githubusercontent.com/AzeemIdr662/IMEI-TAC-DATABASE/main/TAC.csv"
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

# Cek apakah cache ada dan masih fresh (max 24 jam)
CACHE_VALID=false
if [ -f "$TAC_CACHE" ]; then
    CACHE_AGE=$(( $(date +%s) - $(stat -c %Y "$TAC_CACHE" 2>/dev/null || echo 0) ))
    if [ $CACHE_AGE -lt 86400 ]; then
        CACHE_VALID=true
        echo ">>> [TAC] Menggunakan cache lokal ($(wc -l < "$TAC_CACHE") devices)"
    fi
fi

# Download jika cache tidak valid
if [ "$CACHE_VALID" != true ]; then
    echo ">>> [TAC] Downloading TAC database dari GitHub..."
    DOWNLOAD_SUCCESS=false
    
    for TAC_URL in "${TAC_URLS[@]}"; do
        echo "   → Mencoba: $(basename "$TAC_URL")..."
        if curl -sL --connect-timeout 10 "$TAC_URL" -o /tmp/tacdb_raw.csv 2>/dev/null; then
            # Parse CSV: format bervariasi, coba detect
            # Filter hanya brand populer dan simpan format: TAC|Brand|Model
            grep -iE "samsung|xiaomi|redmi|poco|oppo|realme|vivo|oneplus|huawei|infinix|tecno|asus|sony|motorola|nokia|google|pixel" /tmp/tacdb_raw.csv | \
            awk -F',' '{
                tac=$1; gsub(/[^0-9]/, "", tac);
                if(length(tac)==8) print tac"|"$2"|"$3
            }' | \
            grep -v "^|" | head -500 > "$TAC_CACHE"
            
            TAC_COUNT=$(wc -l < "$TAC_CACHE" 2>/dev/null || echo 0)
            if [ "$TAC_COUNT" -gt 10 ]; then
                echo ">>> [TAC] ✓ Downloaded $TAC_COUNT real device TACs!"
                DOWNLOAD_SUCCESS=true
                break
            fi
        fi
    done
    
    rm -f /tmp/tacdb_raw.csv
    
    if [ "$DOWNLOAD_SUCCESS" != true ]; then
        echo ">>> [TAC] Download gagal, menggunakan built-in database..."
    fi
fi

# Fallback ke built-in jika download gagal
if [ ! -f "$TAC_CACHE" ] || [ $(wc -l < "$TAC_CACHE") -lt 10 ]; then
    echo ">>> [TAC] Menggunakan built-in fallback database..."
    cat > "$TAC_CACHE" << 'EOF'
35332510|Samsung|Galaxy S23 Ultra
35332511|Samsung|Galaxy S23+
35290611|Samsung|Galaxy S22 Ultra
35260010|Samsung|Galaxy S21 Ultra
35456710|Samsung|Galaxy A54
35433010|Samsung|Galaxy A53
35350410|Samsung|Galaxy A52
86769804|Xiaomi|13 Pro
86754303|Xiaomi|12 Pro
86738902|Xiaomi|11T Pro
86720001|Xiaomi|Mi 11
86769901|Redmi|Note 12 Pro
86754401|Redmi|Note 11 Pro
86738801|Redmi|Note 10 Pro
86769801|POCO|F5 Pro
86754201|POCO|X4 Pro
86738701|POCO|X3 Pro
86467502|OPPO|Reno 9 Pro
86452101|OPPO|Reno 7
86421301|OPPO|Find X5 Pro
86467601|Realme|GT 3
86452201|Realme|GT 2 Pro
86421401|Realme|8 Pro
86467701|Vivo|X90 Pro
86452301|Vivo|V27 Pro
86857001|OnePlus|11
86842501|OnePlus|9 Pro
35890001|Infinix|Note 30
EOF
fi

# Pilih TAC random dari file
TOTAL_TACS=$(wc -l < "$TAC_CACHE")
RANDOM_LINE=$((RANDOM % TOTAL_TACS + 1))
TAC_ENTRY=$(sed -n "${RANDOM_LINE}p" "$TAC_CACHE")
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

# ==========================================================
# AUTO DETECT RAM & CPU
# ==========================================================
echo ">>> [HARDWARE] Mendeteksi spesifikasi server..."

# Detect CPU cores
TOTAL_CPU=$(nproc 2>/dev/null || grep -c processor /proc/cpuinfo 2>/dev/null || echo 2)
# Gunakan 75% CPU untuk container (minimal 1)
CONTAINER_CPU=$((TOTAL_CPU * 75 / 100))
[ "$CONTAINER_CPU" -lt 1 ] && CONTAINER_CPU=1

# Detect RAM (dalam MB)
TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo 2>/dev/null | awk '{print $2}' || echo 2097152)
TOTAL_RAM_MB=$((TOTAL_RAM_KB / 1024))
# Sisakan 512MB untuk OS, gunakan sisanya untuk container (minimal 512MB)
CONTAINER_RAM=$((TOTAL_RAM_MB - 512))
[ "$CONTAINER_RAM" -lt 512 ] && CONTAINER_RAM=512

echo "   CPU Total    : ${TOTAL_CPU} cores"
echo "   CPU Container: ${CONTAINER_CPU} cores (75%)"
echo "   RAM Total    : ${TOTAL_RAM_MB} MB"
echo "   RAM Container: ${CONTAINER_RAM} MB (- 512MB reserved)"

# JALANKAN DENGAN --net=host
echo ">>> [START] Menjalankan Android 8 (Host Mode)..."

sudo docker run -d \
    --net=host \
    --cpus="$CONTAINER_CPU" \
    --memory="${CONTAINER_RAM}m" \
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
