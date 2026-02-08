#!/bin/bash

# ==========================================================
#   0. SETUP & WARNA
# ==========================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

clear
echo -e "${CYAN}${BOLD}======================================================${NC}"
echo -e "${CYAN}${BOLD}  SETANG TUYUL TOOLS - FINAL (FIX RANDOM REBOOT)  ${NC}"
echo -e "${CYAN}${BOLD}     200+ DEVICES | ANTI-DETECT | AUTO-CONFIG      ${NC}"
echo -e "${CYAN}${BOLD}======================================================${NC}"
echo ""

if [ "$EUID" -ne 0 ]; then echo -e "${RED}${BOLD}WAJIB ROOT (sudo su)!${NC}"; exit; fi

# Install Dependencies
if ! command -v docker &> /dev/null || ! command -v adb &> /dev/null; then
    echo -e "${YELLOW}>>> [INSTALL] Docker & ADB...${NC}"
    apt-get update -y >/dev/null 2>&1
    apt-get install -y docker.io android-tools-adb curl unzip dos2unix coreutils >/dev/null 2>&1
    systemctl start docker; systemctl enable docker
fi

# ==========================================================
#   1. NUCLEAR CLEAN (PEMBERSIHAN TOTAL)
# ==========================================================
echo -e "${YELLOW}>>> [CLEAN] Membersihkan Sisa Data Lama...${NC}"
docker rm -f android_11 >/dev/null 2>&1
systemctl stop docker.socket >/dev/null 2>&1
systemctl stop docker >/dev/null 2>&1

# HAPUS FOLDER DATA (Mencegah nama device nyangkut)
rm -rf ~/data_11
rm -rf data*
mkdir -p ~/data_11

# Refresh Kernel
rmmod binder_linux >/dev/null 2>&1; rmmod ashmem_linux >/dev/null 2>&1
umount /dev/binderfs >/dev/null 2>&1; rm -rf /dev/binderfs
modprobe binder_linux devices="binder,hwbinder,vndbinder"
modprobe ashmem_linux
mkdir -p /dev/binderfs
mount -t binder binder /dev/binderfs
chmod 777 /dev/binderfs/*
[ ! -e /dev/ashmem ] && mknod /dev/ashmem c 10 61
chmod 777 /dev/ashmem

systemctl start docker; sleep 3

# ==========================================================
#   2. DATABASE 200+ DEVICE (SETANG LIST)
#   Format: Brand|Manuf|Marketing Name|Fingerprint
# ==========================================================
DEVICES=(
    # --- OPPO ---
    "OPPO|OPPO|Reno 9 Pro+|OPPO/PGW110/PGW110:13/TP1A.220905.001/1675850901:user/release-keys"
    "OPPO|OPPO|Reno 9|OPPO/PHM110/PHM110:13/TP1A.220905.001/1675850901:user/release-keys"
    "OPPO|OPPO|Reno 8 Pro|OPPO/CPH2357/CPH2357:12/SP1A.210812.016/1660230230:user/release-keys"
    "OPPO|OPPO|Reno 8 5G|OPPO/CPH2359/CPH2359:12/SP1A.210812.016/1660230230:user/release-keys"
    "OPPO|OPPO|Reno 7 Pro|OPPO/CPH2293/CPH2293:11/RP1A.200720.011/1640105050:user/release-keys"
    "OPPO|OPPO|Reno 7 5G|OPPO/CPH2371/CPH2371:11/RP1A.200720.011/1640105050:user/release-keys"
    "OPPO|OPPO|Reno 6 Pro|OPPO/CPH2247/CPH2247:11/RP1A.200720.011/1620815467:user/release-keys"
    "OPPO|OPPO|Reno 6 5G|OPPO/CPH2251/CPH2251:11/RP1A.200720.011/1620815467:user/release-keys"
    "OPPO|OPPO|Reno 5 Pro|OPPO/CPH2201/CPH2201:11/RP1A.200720.011/1620815467:user/release-keys"
    "OPPO|OPPO|Reno 5|OPPO/CPH2159/CPH2159:11/RP1A.200720.011/1620815467:user/release-keys"
    "OPPO|OPPO|Reno 4 Pro|OPPO/CPH2109/CPH2109:10/QKQ1.200614.002/1598426543:user/release-keys"
    "OPPO|OPPO|Reno 4|OPPO/CPH2113/CPH2113:10/QKQ1.200614.002/1598426543:user/release-keys"
    "OPPO|OPPO|Find X5 Pro|OPPO/PFEM10/PFEM10:13/TP1A.220905.001/1675850901:user/release-keys"
    "OPPO|OPPO|Find X5|OPPO/PFFM10/PFFM10:13/TP1A.220905.001/1675850901:user/release-keys"
    "OPPO|OPPO|Find X3 Pro|OPPO/PEEM00/PEEM00:12/SP1A.210812.016/1640105050:user/release-keys"
    "OPPO|OPPO|Find X2 Pro|OPPO/CPH2025/CPH2025:11/RP1A.200720.011/1620815467:user/release-keys"
    "OPPO|OPPO|A96|OPPO/CPH2333/CPH2333:11/RP1A.200720.011/1640105050:user/release-keys"
    "OPPO|OPPO|A77s|OPPO/CPH2473/CPH2473:12/SP1A.210812.016/1660230230:user/release-keys"
    "OPPO|OPPO|A76|OPPO/CPH2375/CPH2375:11/RP1A.200720.011/1640105050:user/release-keys"
    "OPPO|OPPO|A74 5G|OPPO/CPH2197/CPH2197:11/RP1A.200720.011/1620815467:user/release-keys"
    "OPPO|OPPO|A57|OPPO/CPH2387/CPH2387:12/SP1A.210812.016/1660230230:user/release-keys"
    "OPPO|OPPO|A55|OPPO/CPH2325/CPH2325:11/RP1A.200720.011/1640105050:user/release-keys"
    "OPPO|OPPO|A54|OPPO/CPH2239/CPH2239:10/QKQ1.200614.002/1620815467:user/release-keys"
    "OPPO|OPPO|A53|OPPO/CPH2127/CPH2127:10/QKQ1.200614.002/1598426543:user/release-keys"
    "OPPO|OPPO|A17|OPPO/CPH2477/CPH2477:12/SP1A.210812.016/1660230230:user/release-keys"
    "OPPO|OPPO|A16|OPPO/CPH2269/CPH2269:11/RP1A.200720.011/1620815467:user/release-keys"
    "OPPO|OPPO|A15|OPPO/CPH2185/CPH2185:10/QKQ1.200614.002/1598426543:user/release-keys"

    # --- VIVO ---
    "vivo|vivo|X90 Pro+|vivo/V2227A/V2227A:13/TP1A.220624.014/compiler08252243:user/release-keys"
    "vivo|vivo|X90|vivo/V2241/V2241:13/TP1A.220624.014/compiler08252243:user/release-keys"
    "vivo|vivo|X80 Pro|vivo/V2145/V2145:12/SP1A.210812.003/compiler03161830:user/release-keys"
    "vivo|vivo|X80|vivo/V2144/V2144:12/SP1A.210812.003/compiler03161830:user/release-keys"
    "vivo|vivo|X70 Pro+|vivo/V2145A/V2145A:11/RP1A.200720.012/compiler08252243:user/release-keys"
    "vivo|vivo|X70 Pro|vivo/V2105/V2105:11/RP1A.200720.012/compiler08252243:user/release-keys"
    "vivo|vivo|X60 Pro|vivo/V2046/V2046:11/RP1A.200720.012/compiler08252243:user/release-keys"
    "vivo|vivo|V27 Pro|vivo/V2230/V2230:13/TP1A.220624.014/compiler08252243:user/release-keys"
    "vivo|vivo|V27|vivo/V2246/V2246:13/TP1A.220624.014/compiler08252243:user/release-keys"
    "vivo|vivo|V25 Pro|vivo/V2158/V2158:12/SP1A.210812.003/compiler03161830:user/release-keys"
    "vivo|vivo|V25|vivo/V2202/V2202:12/SP1A.210812.003/compiler03161830:user/release-keys"
    "vivo|vivo|V23 Pro|vivo/V2132/V2132:12/SP1A.210812.003/compiler03161830:user/release-keys"
    "vivo|vivo|V23 5G|vivo/V2130/V2130:12/SP1A.210812.003/compiler03161830:user/release-keys"
    "vivo|vivo|V21 5G|vivo/V2050/V2050:11/RP1A.200720.012/compiler08252243:user/release-keys"
    "vivo|vivo|V20 Pro|vivo/V2018/V2018:11/RP1A.200720.012/compiler08252243:user/release-keys"
    "vivo|vivo|V20|vivo/V2025/V2025:11/RP1A.200720.012/compiler08252243:user/release-keys"
    "vivo|vivo|Y100|vivo/V2239/V2239:13/TP1A.220624.014/compiler08252243:user/release-keys"
    "vivo|vivo|Y35|vivo/V2205/V2205:12/SP1A.210812.003/compiler03161830:user/release-keys"
    "vivo|vivo|Y22|vivo/V2207/V2207:12/SP1A.210812.003/compiler03161830:user/release-keys"
    "vivo|vivo|Y21|vivo/V2111/V2111:11/RP1A.200720.012/compiler08252243:user/release-keys"
    "vivo|vivo|Y33s|vivo/V2109/V2109:11/RP1A.200720.012/compiler08252243:user/release-keys"
    "vivo|vivo|Y20s|vivo/V2029/V2029:10/QP1A.190711.020/compiler08031853:user/release-keys"
    "vivo|vivo|Y12s|vivo/V2026/V2026:10/QP1A.190711.020/compiler08031853:user/release-keys"
    "vivo|vivo|T1 5G|vivo/V2141/V2141:12/SP1A.210812.003/compiler03161830:user/release-keys"
    "vivo|vivo|T1 Pro|vivo/V2151/V2151:12/SP1A.210812.003/compiler03161830:user/release-keys"

    # --- REALME ---
    "realme|realme|GT3|realme/RMX3709/RMX3709:13/TP1A.220905.001/1676882294:user/release-keys"
    "realme|realme|GT Neo 5|realme/RMX3706/RMX3706:13/TP1A.220905.001/1676882294:user/release-keys"
    "realme|realme|GT 2 Pro|realme/RMX3301/RMX3301:13/TP1A.220905.001/1676882294:user/release-keys"
    "realme|realme|GT 2|realme/RMX3312/RMX3312:12/SP1A.210812.016/1640105050:user/release-keys"
    "realme|realme|GT Neo 3|realme/RMX3561/RMX3561:12/SP1A.210812.016/1652432223:user/release-keys"
    "realme|realme|GT Neo 2|realme/RMX3370/RMX3370:11/RP1A.200720.011/1640105050:user/release-keys"
    "realme|realme|GT Master|realme/RMX3363/RMX3363:11/RP1A.200720.011/1626337852:user/release-keys"
    "realme|realme|GT 5G|realme/RMX2202/RMX2202:11/RP1A.200720.011/1618386345:user/release-keys"
    "realme|realme|10 Pro+|realme/RMX3686/RMX3686:13/TP1A.220905.001/1676882294:user/release-keys"
    "realme|realme|10 Pro|realme/RMX3660/RMX3660:13/TP1A.220905.001/1676882294:user/release-keys"
    "realme|realme|10 4G|realme/RMX3630/RMX3630:12/SP1A.210812.016/1660230230:user/release-keys"
    "realme|realme|9 Pro+|realme/RMX3392/RMX3392:12/SP1A.210812.016/1652432223:user/release-keys"
    "realme|realme|9 Pro|realme/RMX3471/RMX3471:12/SP1A.210812.016/1648197365:user/release-keys"
    "realme|realme|9i|realme/RMX3491/RMX3491:11/RP1A.200720.011/1640105050:user/release-keys"
    "realme|realme|8 Pro|realme/RMX3081/RMX3081:11/RP1A.200720.011/1618386345:user/release-keys"
    "realme|realme|8 5G|realme/RMX3241/RMX3241:11/RP1A.200720.011/1626337852:user/release-keys"
    "realme|realme|7 Pro|realme/RMX2170/RMX2170:10/QKQ1.191222.002/1602737666:user/release-keys"
    "realme|realme|Narzo 50|realme/RMX3286/RMX3286:11/RP1A.200720.011/1640105050:user/release-keys"
    "realme|realme|Narzo 50A|realme/RMX3430/RMX3430:11/RP1A.200720.011/1640105050:user/release-keys"
    "realme|realme|C55|realme/RMX3710/RMX3710:13/TP1A.220905.001/1676882294:user/release-keys"
    "realme|realme|C35|realme/RMX3511/RMX3511:11/RP1A.200720.011/1640105050:user/release-keys"
    "realme|realme|C25|realme/RMX3191/RMX3191:11/RP1A.200720.011/1618386345:user/release-keys"

    # --- INFINIX & TECNO ---
    "Infinix|Infinix|Zero Ultra|Infinix/X6820/Infinix-X6820:12/SP1A.210812.016/220719V453:user/release-keys"
    "Infinix|Infinix|Note 12 Pro|Infinix/X676B/Infinix-X676B:12/SP1A.210812.016/220719V453:user/release-keys"
    "Infinix|Infinix|Note 12|Infinix/X670/Infinix-X670:12/SP1A.210812.016/220719V453:user/release-keys"
    "Infinix|Infinix|Note 11|Infinix/X663/Infinix-X663:11/RP1A.200720.011/211230V350:user/release-keys"
    "Infinix|Infinix|Hot 20|Infinix/X6826/Infinix-X6826:12/SP1A.210812.016/220719V453:user/release-keys"
    "Infinix|Infinix|Hot 12|Infinix/X6817/Infinix-X6817:11/RP1A.200720.011/220110V500:user/release-keys"
    "Infinix|Infinix|Hot 11|Infinix/X662/Infinix-X662:11/RP1A.200720.011/210823V367:user/release-keys"
    "TECNO|TECNO|Phantom X2 Pro|TECNO/AD9/TECNO-AD9:12/SP1A.210812.016/220719V453:user/release-keys"
    "TECNO|TECNO|Phantom X2|TECNO/AD8/TECNO-AD8:12/SP1A.210812.016/220719V453:user/release-keys"
    "TECNO|TECNO|Camon 19 Pro|TECNO/CI8/TECNO-CI8:12/SP1A.210812.016/220719V453:user/release-keys"
    "TECNO|TECNO|Camon 18 Premier|TECNO/CH9/TECNO-CH9:11/RP1A.200720.011/210816V298:user/release-keys"
    "TECNO|TECNO|Pova 4|TECNO/LG7n/TECNO-LG7n:12/SP1A.210812.016/220719V453:user/release-keys"
    "TECNO|TECNO|Pova 3|TECNO/LF7/TECNO-LF7:11/RP1A.200720.011/220110V500:user/release-keys"
    "TECNO|TECNO|Spark 9 Pro|TECNO/KH7/TECNO-KH7:12/SP1A.210812.016/220719V453:user/release-keys"

    # --- ONEPLUS ---
    "OnePlus|OnePlus|OnePlus 11|OnePlus/CPH2449/CPH2449:13/TP1A.220905.001/S.202302241645:user/release-keys"
    "OnePlus|OnePlus|OnePlus 10 Pro|OnePlus/NE2213/NE2213:12/SKQ1.211113.001/NE2213_11_A.13:user/release-keys"
    "OnePlus|OnePlus|Nord 2T|OnePlus/CPH2401/CPH2401:12/SP1A.210812.016/S.202302241645:user/release-keys"

    # --- XIAOMI ---
    "Xiaomi|Xiaomi|Xiaomi 13|Xiaomi/fuxi_global/fuxi:13/TKQ1.221114.001/V14.0.1.0.TMCMIXM:user/release-keys"
    "Xiaomi|Xiaomi|Xiaomi 12|Xiaomi/cupid_global/cupid:13/TKQ1.220829.002/V14.0.1.0.TLCMIXM:user/release-keys"
    "Xiaomi|Xiaomi|Xiaomi 12X|Xiaomi/psyche_global/psyche:12/SKQ1.211006.001/V13.0.1.0.SLDMIXM:user/release-keys"
    "Xiaomi|Xiaomi|Xiaomi 11T|Xiaomi/agate_global/agate:12/SKQ1.211006.001/V13.0.2.0.SKWMIXM:user/release-keys"
    "Xiaomi|Xiaomi|Xiaomi 11T Pro|Xiaomi/vili_global/vili:12/SKQ1.211006.001/V13.0.1.0.SKDMIXM:user/release-keys"
    "Xiaomi|Xiaomi|Mi 11|Xiaomi/venus_global/venus:12/SKQ1.211006.001/V13.0.1.0.SKBMIXM:user/release-keys"
    "Xiaomi|Xiaomi|Mi 11 Ultra|Xiaomi/star_global/star:12/SKQ1.211006.001/V13.0.1.0.SKAMIXM:user/release-keys"
    "Xiaomi|Xiaomi|Mi 11 Lite|Xiaomi/courbet_global/courbet:12/SKQ1.211006.001/V13.0.4.0.SKQMIXM:user/release-keys"
    "Xiaomi|Xiaomi|Mi 11 Lite 5G|Xiaomi/renoir_global/renoir:12/SKQ1.211006.001/V13.0.2.0.SKIMIXM:user/release-keys"
    "Xiaomi|Xiaomi|Mi 11i|Xiaomi/haydn_global/haydn:12/SKQ1.211006.001/V13.0.1.0.SKKMIXM:user/release-keys"
    "Xiaomi|Xiaomi|Mi 10|Xiaomi/umi/umi:11/RKQ1.200826.002/V12.2.7.0.RJBMIXM:user/release-keys"
    "Xiaomi|Xiaomi|Mi 10 Pro|Xiaomi/cmi/cmi:11/RKQ1.200826.002/V12.2.6.0.RJAMIXM:user/release-keys"
    "Xiaomi|Xiaomi|Mi 10T|Xiaomi/apollo_global/apollo:11/RKQ1.200826.002/V12.5.1.0.RJDMIXM:user/release-keys"
    "Xiaomi|Xiaomi|Mi 10T Pro|Xiaomi/apollo_global/apollo:11/RKQ1.200826.002/V12.5.1.0.RJDMIXM:user/release-keys"
    "Xiaomi|Xiaomi|Mi 10 Lite|Xiaomi/monet_global/monet:11/RKQ1.200826.002/V12.1.2.0.RJIMIXM:user/release-keys"
    "Xiaomi|Xiaomi|Mi 9|Xiaomi/cepheus/cepheus:10/QKQ1.190825.002/V12.0.1.0.QFAMIXM:user/release-keys"
    "Xiaomi|Xiaomi|Mi 9T|Xiaomi/davinci_global/davinci:10/QKQ1.190825.002/V12.0.3.0.QFJMIXM:user/release-keys"
    "Xiaomi|Xiaomi|Mi 9T Pro|Xiaomi/raphael_global/raphael:10/QKQ1.190825.002/V12.0.1.0.QFKMIXM:user/release-keys"
    "Xiaomi|Xiaomi|Mi 9 SE|Xiaomi/grus/grus:10/QKQ1.190825.002/V12.0.1.0.QFBMIXM:user/release-keys"
    "Xiaomi|Xiaomi|Mi 8|Xiaomi/dipper/dipper:10/QKQ1.190825.002/V11.0.6.0.QEAMIXM:user/release-keys"
    "Xiaomi|Xiaomi|Mi Mix 3|Xiaomi/perseus/perseus:10/QKQ1.190825.002/V11.0.3.0.QEEMIXM:user/release-keys"
    "Xiaomi|Xiaomi|Mi Mix 2S|Xiaomi/polaris/polaris:10/QKQ1.190825.002/V11.0.3.0.QDGMIXM:user/release-keys"
    "Xiaomi|Xiaomi|Mi A3|Xiaomi/laurel_sprout/laurel_sprout:11/RKQ1.200903.002/V12.0.3.0.RFQMIXM:user/release-keys"
    "Redmi|Xiaomi|Redmi Note 12|Redmi/topaz_global/topaz:13/TKQ1.221114.001/V14.0.2.0.TMGMIXM:user/release-keys"
    "Redmi|Xiaomi|Redmi Note 12 Pro|Redmi/ruby_global/ruby:13/TKQ1.221114.001/V14.0.2.0.TMOEUXM:user/release-keys"
    "Redmi|Xiaomi|Redmi Note 11|Redmi/spes_global/spes:12/SKQ1.211006.001/V13.0.5.0.SGCMIXM:user/release-keys"
    "Redmi|Xiaomi|Redmi Note 11 Pro|Redmi/veux_global/veux:12/SKQ1.211006.001/V13.0.2.0.SGDMIXM:user/release-keys"
    "Redmi|Xiaomi|Redmi Note 11S|Redmi/fleur_global/fleur:12/SKQ1.211006.001/V13.0.5.0.SKEMIXM:user/release-keys"
    "Redmi|Xiaomi|Redmi Note 10|Redmi/mojito_global/mojito:12/SKQ1.210908.001/V13.0.4.0.SKGMIXM:user/release-keys"
    "Redmi|Xiaomi|Redmi Note 10 Pro|Redmi/sweet_global/sweet:12/SKQ1.210908.001/V13.0.8.0.SKFMIXM:user/release-keys"
    "Redmi|Xiaomi|Redmi Note 10S|Redmi/rosemary_global/rosemary:12/SKQ1.210908.001/V13.0.4.0.SKLMIXM:user/release-keys"
    "Redmi|Xiaomi|Redmi Note 10 5G|Redmi/camellian_global/camellian:12/SKQ1.210908.001/V13.0.2.0.SKSMIXM:user/release-keys"
    "Redmi|Xiaomi|Redmi Note 9|Redmi/merlin_global/merlin:11/RP1A.200720.011/V12.5.4.0.RJOMIXM:user/release-keys"
    "Redmi|Xiaomi|Redmi Note 9S|Redmi/curtana_global/curtana:11/RP1A.200720.011/V12.5.1.0.RJWMIXM:user/release-keys"
    "Redmi|Xiaomi|Redmi Note 9 Pro|Redmi/joyeuse_global/joyeuse:11/RP1A.200720.011/V12.5.1.0.RJZMIXM:user/release-keys"
    "Redmi|Xiaomi|Redmi Note 9T|Redmi/cannong_global/cannong:11/RP1A.200720.011/V12.5.5.0.RJEMIXM:user/release-keys"
    "Redmi|Xiaomi|Redmi Note 8|Redmi/ginkgo/ginkgo:10/QKQ1.200114.002/V12.0.4.0.QCOMIXM:user/release-keys"
    "Redmi|Xiaomi|Redmi Note 8 Pro|Redmi/begonia/begonia:10/QP1A.190711.020/V12.0.5.0.QGGMIXM:user/release-keys"
    "Redmi|Xiaomi|Redmi Note 8T|Redmi/willow/willow:10/QKQ1.200114.002/V12.0.3.0.QCXMIXM:user/release-keys"
    "Redmi|Xiaomi|Redmi Note 7|Redmi/lavender/lavender:10/QKQ1.190910.002/V11.0.6.0.QFGMIXM:user/release-keys"
    "Redmi|Xiaomi|Redmi 10|Redmi/selene_global/selene:12/SKQ1.211006.001/V13.0.1.0.SKUMIXM:user/release-keys"
    "Redmi|Xiaomi|Redmi 10C|Redmi/fog_global/fog:11/RP1A.200720.011/V13.0.2.0.RGEMIXM:user/release-keys"
    "Redmi|Xiaomi|Redmi 9|Redmi/lancelot/lancelot:10/QP1A.190711.020/V11.0.9.0.QJCMIXM:user/release-keys"
    "Redmi|Xiaomi|Redmi 9A|Redmi/dandelion/dandelion:10/QP1A.190711.020/V12.0.10.0.QCDMIXM:user/release-keys"
    "Redmi|Xiaomi|Redmi 9C|Redmi/angelica/angelica:10/QP1A.190711.020/V12.0.10.0.QCRMIXM:user/release-keys"
    "Redmi|Xiaomi|Redmi 9T|Redmi/lemon_global/lemon:10/QKQ1.200830.002/V12.0.4.0.QJQMIXM:user/release-keys"
    "Redmi|Xiaomi|Redmi 8|Redmi/olive/olive:10/QKQ1.191014.001/V11.0.2.0.QCNMIXM:user/release-keys"
    "Redmi|Xiaomi|Redmi 8A|Redmi/olivelite/olivelite:10/QKQ1.191014.001/V11.0.2.0.QCPMIXM:user/release-keys"
    "Redmi|Xiaomi|Redmi K40|Xiaomi/alioth/alioth:12/SKQ1.211006.001/V13.0.2.0.SKHCNXM:user/release-keys"
    "Redmi|Xiaomi|Redmi K30 Pro|Xiaomi/lmi/lmi:11/RKQ1.200826.002/V12.2.4.0.RJKCNXM:user/release-keys"
    "Redmi|Xiaomi|Redmi K20 Pro|Xiaomi/raphael/raphael:10/QKQ1.190825.002/V12.0.3.0.QFKCNXM:user/release-keys"
    "POCO|Xiaomi|POCO F5|POCO/marble_global/marble:13/TKQ1.221114.001/V14.0.1.0.TMRMIXM:user/release-keys"
    "POCO|Xiaomi|POCO F5 Pro|POCO/mondrian_global/mondrian:13/TKQ1.221114.001/V14.0.1.0.TMNMIXM:user/release-keys"
    "POCO|Xiaomi|POCO X5 Pro|POCO/redwood_global/redwood:12/SKQ1.211006.001/V14.0.1.0.SMSMIXM:user/release-keys"
    "POCO|Xiaomi|POCO X4 Pro 5G|POCO/veux_global/veux:12/SKQ1.211006.001/V13.0.2.0.SKCMIXM:user/release-keys"
    "POCO|Xiaomi|POCO X4 GT|POCO/xaga_global/xaga:12/SKQ1.211006.001/V13.0.3.0.SLOMIXM:user/release-keys"
    "POCO|Xiaomi|POCO F4|POCO/munch_global/munch:12/SKQ1.211006.001/V13.0.3.0.SLMMIXM:user/release-keys"
    "POCO|Xiaomi|POCO F4 GT|POCO/ingres_global/ingres:12/SKQ1.211006.001/V13.0.2.0.SLJMIXM:user/release-keys"
    "POCO|Xiaomi|POCO X3 Pro|POCO/vayu_global/vayu:12/SKQ1.211006.001/V13.0.1.0.SJUMIXM:user/release-keys"
    "POCO|Xiaomi|POCO X3 NFC|POCO/surya_global/surya:11/RKQ1.200826.002/V12.5.3.0.RJGMIXM:user/release-keys"
    "POCO|Xiaomi|POCO F3|POCO/alioth_global/alioth:12/SKQ1.211006.001/V13.0.2.0.SKHMIXM:user/release-keys"
    "POCO|Xiaomi|POCO F2 Pro|POCO/lmi_global/lmi:11/RKQ1.200826.002/V12.2.4.0.RJKMIXM:user/release-keys"
    "POCO|Xiaomi|POCO F1|POCO/beryllium_global/beryllium:10/QKQ1.190828.002/V12.0.3.0.QEJMIXM:user/release-keys"
    "POCO|Xiaomi|POCO X5 5G|POCO/moonstone_global/moonstone:13/TKQ1.221114.001/V14.0.1.0.TMPMIXM:user/release-keys"
    "POCO|Xiaomi|POCO M5|POCO/rock_global/rock:12/SP1A.210812.016/V13.0.2.0.SLUMIXM:user/release-keys"
    "POCO|Xiaomi|POCO M5s|POCO/rosemary_p_global/rosemary:12/SP1A.210812.016/V13.0.2.0.SFFMIXM:user/release-keys"
    "POCO|Xiaomi|POCO M4 Pro|POCO/fleur_global/fleur:11/RP1A.200720.011/V13.0.2.0.RKEMIXM:user/release-keys"
    "POCO|Xiaomi|POCO M4 5G|POCO/light_global/light:12/SP1A.210812.016/V13.0.2.0.SLSMIXM:user/release-keys"
    "POCO|Xiaomi|POCO M3|POCO/citrus_global/citrus:10/QKQ1.200830.002/V12.0.9.0.QJFMIXM:user/release-keys"
    "POCO|Xiaomi|POCO M3 Pro 5G|POCO/camellian_global/camellian:11/RP1A.200720.011/V12.5.2.0.RKSMIXM:user/release-keys"
    "POCO|Xiaomi|POCO C40|POCO/frost_global/frost:11/RP1A.200720.011/V13.0.1.0.RGFMIXM:user/release-keys"

    # --- SAMSUNG ---
    "Samsung|Samsung|SM-S918B|samsung/dm3q/dm3q:13/TP1A.220624.014/S918BXXU1BWK4:user/release-keys"
    "Samsung|Samsung|SM-S901B|samsung/r0s/r0s:13/TP1A.220624.014/S901BXXU2BVJA:user/release-keys"
    "Samsung|Samsung|SM-S906B|samsung/r0q/r0q:13/TP1A.220624.014/S906BXXU2BVJA:user/release-keys"
    "Samsung|Samsung|SM-S908B|samsung/g0q/g0q:13/TP1A.220624.014/S908BXXU2BVJA:user/release-keys"
    "Samsung|Samsung|SM-G991B|samsung/o1s/o1s:12/SP1A.210812.016/G991BXXU4BUL6:user/release-keys"
    "Samsung|Samsung|SM-G996B|samsung/p2s/p2s:12/SP1A.210812.016/G996BXXU4BUL6:user/release-keys"
    "Samsung|Samsung|SM-G998B|samsung/p3s/p3s:12/SP1A.210812.016/G998BXXU4BUL6:user/release-keys"
    "Samsung|Samsung|SM-G780F|samsung/r8s/r8s:11/RP1A.200720.012/G780FXXU2CUA2:user/release-keys"
    "Samsung|Samsung|SM-G781B|samsung/r8q/r8q:12/SP1A.210812.016/G781BXXU4DVE3:user/release-keys"
    "Samsung|Samsung|SM-A736B|samsung/a73xq/a73xq:12/SP1A.210812.016/A736BXXU1AVF3:user/release-keys"
    "Samsung|Samsung|SM-A546E|samsung/a54x/a54x:13/TP1A.220624.014/A546EXXU1AWD4:user/release-keys"
    "Samsung|Samsung|SM-A536B|samsung/a53x/a53x:12/SP1A.210812.016/A536BXXU1AVD1:user/release-keys"
    "Samsung|Samsung|SM-A528B|samsung/a52sxq/a52sxq:12/SP1A.210812.016/A528BXXU1CVG2:user/release-keys"
    "Samsung|Samsung|SM-A525F|samsung/a52/a52:12/SP1A.210812.016/A525FXXU4BVE1:user/release-keys"
    "Samsung|Samsung|SM-A336B|samsung/a33x/a33x:12/SP1A.210812.016/A336BXXU2AVF2:user/release-keys"
    "Samsung|Samsung|SM-A325F|samsung/a32/a32:11/RP1A.200720.012/A325FXXU2AUD4:user/release-keys"
    "Samsung|Samsung|SM-A225F|samsung/a22/a22:11/RP1A.200720.012/A225FXXU2AUH1:user/release-keys"
    "Samsung|Samsung|SM-A135F|samsung/a13/a13:12/SP1A.210812.016/A135FXXU1AVF1:user/release-keys"
    "Samsung|Samsung|SM-A125F|samsung/a12/a12:11/RP1A.200720.012/A125FXXU1BUE3:user/release-keys"
    "Samsung|Samsung|SM-A035F|samsung/a03/a03:11/RP1A.200720.012/A035FXXU1AVA3:user/release-keys"
    "Samsung|Samsung|SM-A025F|samsung/a02s/a02s:10/QP1A.190711.020/A025FXXU2BUC1:user/release-keys"
    "Samsung|Samsung|SM-M536B|samsung/m53x/m53x:12/SP1A.210812.016/M536BXXU1AVD6:user/release-keys"
    "Samsung|Samsung|SM-M526B|samsung/m52xq/m52xq:11/RP1A.200720.012/M526BXXU1AUJ2:user/release-keys"
    "Samsung|Samsung|SM-M325F|samsung/m32/m32:11/RP1A.200720.012/M325FVXXU2AUJ3:user/release-keys"
    "Samsung|Samsung|SM-M225FV|samsung/m22/m22:11/RP1A.200720.012/M225FVXXU2AUJ3:user/release-keys"
    "Samsung|Samsung|SM-M127F|samsung/m12/m12:11/RP1A.200720.012/M127FXXU1BUD8:user/release-keys"
    "Samsung|Samsung|SM-E5260|samsung/m52xq/m52xq:11/RP1A.200720.012/E5260ZCU1AUJ2:user/release-keys"
    "Samsung|Samsung|SM-G781B|samsung/r8q/r8q:13/TP1A.220624.014/G781BXXU4HWD1:user/release-keys"
    "Samsung|Samsung|SM-X700|samsung/gts8/gts8:13/TP1A.220624.014/X700XXU3BWD1:user/release-keys"

    # --- ASUS ---
    "asus|asus|Zenfone 9|asus/WW_AI2202/ASUS_AI2202:13/TKQ1.220829.002/33.0804.2060.113:user/release-keys"
    "asus|asus|Zenfone 8|asus/WW_I006D/ASUS_I006D:12/SKQ1.211006.001/31.1010.0411.76:user/release-keys"
    "asus|asus|Zenfone 8 Flip|asus/WW_I004D/ASUS_I004D:12/SKQ1.211006.001/31.1010.0411.76:user/release-keys"
    "asus|asus|Zenfone 7 Pro|asus/WW_I002D/ASUS_I002D:11/RKQ1.201022.002/30.41.69.66:user/release-keys"
    "asus|asus|ROG Phone 6D|asus/WW_AI2203/ASUS_AI2203:12/SKQ1.211006.001/18.0840.2109.176:user/release-keys"
    "asus|asus|ROG Phone 6|asus/WW_AI2201/ASUS_AI2201:12/SKQ1.211006.001/18.0840.2109.176:user/release-keys"
    "asus|asus|ROG Phone 5s|asus/WW_I005D/ASUS_I005D:11/RKQ1.201022.002/18.1220.2109.131:user/release-keys"
    "asus|asus|ROG Phone 5|asus/WW_I005D/ASUS_I005D:11/RKQ1.201022.002/18.0840.2104.56:user/release-keys"
    "asus|asus|ROG Phone 3|asus/WW_I003D/ASUS_I003D:10/QKQ1.190825.002/17.0823.2008.78:user/release-keys"
    "asus|asus|ROG Phone 2|asus/WW_I001D/ASUS_I001D:9/PKQ1.190302.001/16.0631.1910.35:user/release-keys"

    # --- SONY ---
    "Sony|Sony|Xperia 1 IV|Sony/XQ-CT54_EEA/XQ-CT54:13/TKQ1.220807.001/64.1.A.0.869:user/release-keys"
    "Sony|Sony|Xperia 5 IV|Sony/XQ-CQ54_EEA/XQ-CQ54:13/TKQ1.220807.001/64.1.A.0.869:user/release-keys"
    "Sony|Sony|Xperia 10 IV|Sony/XQ-CC54_EEA/XQ-CC54:12/SKQ1.211006.001/65.1.A.3.50:user/release-keys"
    "Sony|Sony|Xperia 1 III|Sony/XQ-BC52_EEA/XQ-BC52:12/SKQ1.211006.001/61.1.A.4.78:user/release-keys"
    "Sony|Sony|Xperia 5 III|Sony/XQ-BQ52_EEA/XQ-BQ52:12/SKQ1.211006.001/61.1.A.4.78:user/release-keys"
    "Sony|Sony|Xperia 10 III|Sony/XQ-BT52_EEA/XQ-BT52:11/RP1A.200720.012/62.0.A.3.131:user/release-keys"
    "Sony|Sony|Xperia 1 II|Sony/XQ-AT51_EEA/XQ-AT51:11/RP1A.200720.012/58.1.A.5.530:user/release-keys"
    "Sony|Sony|Xperia 5 II|Sony/XQ-AS52_EEA/XQ-AS52:11/RP1A.200720.012/58.1.A.5.530:user/release-keys"
    "Sony|Sony|Xperia 1|Sony/J9110_EEA/J9110:10/QKQ1.190825.002/55.1.A.9.21:user/release-keys"
    "Sony|Sony|Xperia 5|Sony/J9210_EEA/J9210:10/QKQ1.190825.002/55.1.A.9.21:user/release-keys"

    # --- MOTO & HUAWEI ---
    "Motorola|Motorola|Edge 30 Ultra|motorola/eqs_global/eqs:12/S1SQ32.15-20-1/36423:user/release-keys"
    "Motorola|Motorola|Edge 30 Pro|motorola/rogue_global/rogue:12/S1SC32.52-26/186a8:user/release-keys"
    "Motorola|Motorola|Edge 30|motorola/dubai_global/dubai:12/S1RDS32.55-33-2/212a3:user/release-keys"
    "Motorola|Motorola|Edge 20 Pro|motorola/pstar_reteu/pstar:11/RRA31.Q3-19-50/212a3:user/release-keys"
    "Motorola|Motorola|Edge 20|motorola/berlin_reteu/berlin:11/RRG31.Q3-23-20/212a3:user/release-keys"
    "Motorola|Motorola|Moto G200|motorola/xpeng_reteu/xpeng:11/RRX31.Q3-59-18/212a3:user/release-keys"
    "Motorola|Motorola|Moto G82|motorola/rhode_global/rhode:12/S1SUS32.73-112-2/212a3:user/release-keys"
    "Motorola|Motorola|Moto G52|motorola/rhode_global/rhode:12/S1SRS32.38-13-5/212a3:user/release-keys"
    "Huawei|Huawei|P40 Pro|HUAWEI/ELS-NX9/ELS-NX9:10/HUAWEIELS-NX9/10.1.0.176C432:user/release-keys"
    "Huawei|Huawei|P40|HUAWEI/ANA-NX9/ANA-NX9:10/HUAWEIANA-NX9/10.1.0.176C432:user/release-keys"
    "Huawei|Huawei|P30 Pro|HUAWEI/VOG-L29/VOG-L29:10/HUAWEIVOG-L29/10.1.0.133C432:user/release-keys"
    "Huawei|Huawei|P30|HUAWEI/ELE-L29/ELE-L29:10/HUAWEIELE-L29/10.1.0.133C432:user/release-keys"
    "Huawei|Huawei|Mate 40 Pro|HUAWEI/NOH-NX9/NOH-NX9:10/HUAWEINOH-NX9/10.1.0.236C432:user/release-keys"
    "Huawei|Huawei|Mate 30 Pro|HUAWEI/LIO-L29/LIO-L29:10/HUAWEILIO-L29/10.1.0.236C432:user/release-keys"
    "Huawei|Huawei|Mate 20 Pro|HUAWEI/LYA-L29/LYA-L29:10/HUAWEIYA-L29/10.1.0.236C432:user/release-keys"
    "Huawei|Huawei|Nova 9|HUAWEI/NAM-LX9/NAM-LX9:11/HUAWEINAM-LX9/102.0.0.123C432:user/release-keys"
    "Huawei|Huawei|Nova 5T|HUAWEI/YAL-L21/YAL-L21:10/HUAWEIYAL-L21/10.1.0.236C432:user/release-keys"
)

HISTORY_FILE="/root/.used_devices"

# ==========================================================
#   3. FUNGSI CEK KONEKSI (ANTI STUCK)
# ==========================================================
function ensure_connect() {
    echo -e "${YELLOW}>>> [CONNECT] Menghubungkan ke ADB...${NC}"
    adb disconnect localhost:5555 >/dev/null 2>&1
    
    for (( i=1; i<=30; i++ )); do
        adb connect localhost:5555 >/dev/null 2>&1
        sleep 2
        STATE=$(timeout 2 adb -s localhost:5555 get-state 2>/dev/null)
        if [ "$STATE" == "device" ]; then
            echo -e "${GREEN}>>> [OK] Terhubung (Percobaan ke-$i)${NC}"
            return 0
        fi
        echo -n "."
        if [ $((i % 10)) -eq 0 ]; then echo ""; echo -e "${YELLOW}>>> [RETRY] Restarting ADB...${NC}"; adb kill-server; adb start-server; fi
    done
    echo -e "${RED}>>> [ERROR] Gagal terhubung.${NC}"; exit 1
}

# 4. PICK DEVICE
TOTAL_DEVICES=${#DEVICES[@]}
[ ! -f "$HISTORY_FILE" ] && touch "$HISTORY_FILE"
USED_COUNT=$(wc -l < "$HISTORY_FILE")
REMAINING=$((TOTAL_DEVICES - USED_COUNT))

echo -e "${CYAN}==============================================${NC}"
echo -e "${CYAN}>>> SETANG TUYUL-TOOLS (VERSI - FINAL)${NC}"
echo -e "${CYAN}>>> Total: $TOTAL_DEVICES | Sisa: $REMAINING${NC}"
echo -e "${CYAN}==============================================${NC}"

if [ "$REMAINING" -le 0 ]; then echo -e "${RED}[STOP] DB HABIS. Reset: rm $HISTORY_FILE${NC}"; exit 1; fi

while true; do
    RANDOM_INDEX=$((RANDOM % TOTAL_DEVICES))
    IFS='|' read -r TMP_BRAND TMP_MANUF TMP_MODEL TMP_FINGER <<< "${DEVICES[$RANDOM_INDEX]}"
    if ! grep -Fxq "$TMP_MODEL" "$HISTORY_FILE"; then
        BRAND=$TMP_BRAND
        MANUF=$TMP_MANUF
        MARKETING_NAME=$TMP_MODEL # Simpan nama keren
        FINGERPRINT=$TMP_FINGER
        
        # --- SMART LOGIC: MODEL CODE SPLIT ---
        # Jika Brand China, ambil kode mesin dari fingerprint
        if [[ "$BRAND" == "OPPO" || "$BRAND" == "realme" || "$BRAND" == "vivo" || "$BRAND" == "Infinix" || "$BRAND" == "TECNO" || "$BRAND" == "OnePlus" ]]; then
            REAL_MODEL=$(echo "$FINGERPRINT" | cut -d'/' -f2)
        else
            # Samsung/Xiaomi pakai nama model apa adanya
            REAL_MODEL=$TMP_MODEL
        fi
        
        echo "$MARKETING_NAME" >> "$HISTORY_FILE"
        break
    fi
done

# 5. DATA SIM
GEN_IMEI=$(shuf -i 350000000000000-359999999999999 -n 1)
GEN_MAC=$(printf '02:%02x:%02x:%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
RAND_SUFFIX=$(shuf -i 100000000-999999999 -n 1)
GEN_PHONE="+628${RAND_SUFFIX}"
GEN_SERIAL=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
MY_IP=$(curl -s ifconfig.me || echo "Offline")

echo -e "${BLUE}>>> NEW IDENTITY:${NC}"
echo -e "${BLUE}----------------------------------------------${NC}"
echo -e "Brand        : ${BOLD}$BRAND${NC}"
echo -e "Device Name  : ${BOLD}$MARKETING_NAME${NC}"
echo -e "Model Code   : ${BOLD}$REAL_MODEL${NC}"
echo -e "Phone        : ${BOLD}$GEN_PHONE${NC}"
echo -e "IP           : ${BOLD}$MY_IP${NC}"
echo -e "${BLUE}----------------------------------------------${NC}"

# ==========================================================
# AUTO DETECT RAM & CPU
# ==========================================================
echo -e "${YELLOW}>>> [HARDWARE] Mendeteksi spesifikasi server...${NC}"

# Detect CPU cores
TOTAL_CPU=$(nproc 2>/dev/null || grep -c processor /proc/cpuinfo 2>/dev/null || echo 2)
# Gunakan 75% CPU untuk container (minimal 1)
CONTAINER_CPU=$((TOTAL_CPU * 75 / 100))
[ "$CONTAINER_CPU" -lt 1 ] && CONTAINER_CPU=1

# Detect RAM (dalam MB)
TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo 2>/dev/null | awk '{print $2}' || echo 2097152)
TOTAL_RAM_MB=$((TOTAL_RAM_KB / 1024))
# Sisakan 512MB untuk OS, gunakan sisanya untuk container
CONTAINER_RAM=$((TOTAL_RAM_MB - 512))
[ "$CONTAINER_RAM" -lt 512 ] && CONTAINER_RAM=512

echo -e "   CPU Total    : ${BOLD}${TOTAL_CPU} cores${NC}"
echo -e "   CPU Container: ${BOLD}${CONTAINER_CPU} cores (75%)${NC}"
echo -e "   RAM Total    : ${BOLD}${TOTAL_RAM_MB} MB${NC}"
echo -e "   RAM Container: ${BOLD}${CONTAINER_RAM} MB (- 512MB reserved)${NC}"

# 6. RUN CONTAINER (NO QUOTES FIX)
echo -e "${YELLOW}>>> [STARTING] Android 11...${NC}"
# PERHATIKAN: Variabel $REAL_MODEL tidak pakai tanda kutip miring \"...\" lagi.
# Ini agar hasil di HP bersih (contoh: NE2213) bukan ("NE2213").
sudo docker run -d --cpus="$CONTAINER_CPU" --memory="${CONTAINER_RAM}m" --memory-swap="-1" --privileged --restart=always \
    -v ~/data_11:/data -p 5555:5555 --name android_11 \
    redroid/redroid:11.0.0-latest \
    androidboot.redroid_width=720 androidboot.redroid_height=1280 androidboot.redroid_dpi=320 \
    androidboot.redroid_gpu_mode=guest androidboot.redroid_mac="$GEN_MAC" androidboot.serialno="$GEN_SERIAL" \
    ro.product.brand="$BRAND" \
    ro.product.manufacturer="$MANUF" \
    ro.product.model="$REAL_MODEL" \
    ro.product.name="$REAL_MODEL" \
    ro.product.device="$REAL_MODEL" \
    ro.product.board="$REAL_MODEL" \
    ro.build.fingerprint="$FINGERPRINT" \
    ro.ril.oem.imei="$GEN_IMEI" \
    ro.ril.oem.phone_number="$GEN_PHONE" \
    gsm.sim.msisdn="$GEN_PHONE" \
    ro.adb.secure=0 ro.secure=0 ro.debuggable=1 > /dev/null

sleep 5; sudo docker exec android_11 rm -f /data/misc/adb/adb_keys; sudo docker exec android_11 killall adbd

# 7. INJECT & SET DEVICE NAME
echo -e "${YELLOW}>>> [WAIT] Booting (15s)...${NC}"
sleep 15
ensure_connect

echo -e "${GREEN}>>> [INJECT] SIM & Metadata...${NC}"
adb -s localhost:5555 wait-for-device
# Inject Nama Device Keren (Pake kutip biar spasi kebaca)
adb -s localhost:5555 shell settings put global device_name \"$MARKETING_NAME\"
adb -s localhost:5555 shell setprop gsm.sim.operator.alpha "Telkomsel"
adb -s localhost:5555 shell setprop gsm.sim.operator.numeric "51010"
adb -s localhost:5555 shell setprop gsm.sim.state "READY"
adb -s localhost:5555 shell setprop gsm.current.phone-number "$GEN_PHONE"
adb -s localhost:5555 shell setprop gsm.sim.msisdn "$GEN_PHONE"
adb -s localhost:5555 shell setprop line1.number "$GEN_PHONE"
adb -s localhost:5555 shell "pkill -f com.android.phone || killall com.android.phone"
adb -s localhost:5555 shell "killall rild" >/dev/null 2>&1

echo -e "${YELLOW}>>> [REFRESH] Signal...${NC}"
sleep 5
ensure_connect
adb -s localhost:5555 shell setprop gsm.sim.msisdn "$GEN_PHONE"
adb -s localhost:5555 shell setprop line1.number "$GEN_PHONE"

# 8. INSTALL
DUKU_PATH="/root/duku.apk"
DUKU_URL="https://app.flow2hk.cc/packages/android/dukulive/1.4.0/dukulive1768544449.apk"
if [ ! -f "$DUKU_PATH" ]; then echo -e "${YELLOW}>>> [DOWNLOAD] Duku APK...${NC}"; curl -L -o "$DUKU_PATH" "$DUKU_URL"; fi
if [ -f "$DUKU_PATH" ]; then
    echo -e "${GREEN}>>> [INSTALL] Duku Live...${NC}"
    timeout 120 adb -s localhost:5555 install -r "$DUKU_PATH"
    if [ $? -eq 0 ]; then echo -e "${GREEN}${BOLD}>>> [SUKSES] Terpasang!${NC}"; else echo -e "${RED}>>> [FAIL] Install Manual: adb -s localhost:5555 install /root/duku.apk${NC}"; fi
fi
echo -e "${CYAN}==============================================${NC}"
