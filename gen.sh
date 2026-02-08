#!/bin/bash

# ==========================================================
#   0. INSTALL DEPENDENCIES (KHUSUS VPS FRESH)
# ==========================================================

echo ">>> [SETUP] Mempersiapkan VPS Fresh..."

if [ "$EUID" -ne 0 ]; then 
  echo "Tolong jalankan sebagai root (sudo su)"
  exit
fi

if ! command -v docker &> /dev/null || ! command -v adb &> /dev/null; then
    echo ">>> [INSTALL] Menginstall Docker & ADB..."
    apt-get update -y
    apt-get install -y docker.io android-tools-adb curl unzip dos2unix coreutils
    systemctl start docker
    systemctl enable docker
else
    echo ">>> [SKIP] Dependencies sudah terinstall."
fi

# ==========================================================
#   REDROID GEN - ULTIMATE V8 (PRE-DOWNLOAD FIX)
# ==========================================================

# 1. SETUP KERNEL
sudo modprobe binder_linux devices="binder,hwbinder,vndbinder"
sudo modprobe ashmem_linux
sudo mkdir -p /dev/binderfs
sudo mount -t binder binder /dev/binderfs 2>/dev/null
sudo chmod 777 /dev/binderfs/*
[ ! -e /dev/ashmem ] && sudo mknod /dev/ashmem c 10 61
sudo chmod 777 /dev/ashmem

# 2. DATABASE RAKSASA
DEVICES=(
    "samsung|samsung|SM-S918B|samsung/dm3q/dm3q:13/TP1A.220624.014/S918BXXU1BWK4:user/release-keys"
    "samsung|samsung|SM-S911B|samsung/dm1q/dm1q:13/TP1A.220624.014/S911BXXU1BWK4:user/release-keys"
    "samsung|samsung|SM-S908E|samsung/g0q/g0q:12/SP1A.210812.016/S908EXXU2AVF1:user/release-keys"
    "samsung|samsung|SM-S906E|samsung/r0q/r0q:12/SP1A.210812.016/S906EXXU2AVF1:user/release-keys"
    "samsung|samsung|SM-S901E|samsung/r0s/r0s:12/SP1A.210812.016/S901EXXU2AVF1:user/release-keys"
    "samsung|samsung|SM-G998B|samsung/p3s/p3s:11/RP1A.200720.012/G998BXXU3AUDA:user/release-keys"
    "samsung|samsung|SM-G996B|samsung/p2s/p2s:11/RP1A.200720.012/G996BXXU3AUDA:user/release-keys"
    "samsung|samsung|SM-G991B|samsung/o1s/o1s:11/RP1A.200720.012/G991BXXU3AUDA:user/release-keys"
    "samsung|samsung|SM-N986B|samsung/c2s/c2s:11/RP1A.200720.012/N986BXXU1ATH3:user/release-keys"
    "samsung|samsung|SM-N985F|samsung/c2s/c2s:11/RP1A.200720.012/N985FXXU1ATH3:user/release-keys"
    "samsung|samsung|SM-N980F|samsung/c1s/c1s:11/RP1A.200720.012/N980FXXU1ATH3:user/release-keys"
    "samsung|samsung|SM-G988B|samsung/z3s/z3s:11/RP1A.200720.012/G988BXXU1ATH3:user/release-keys"
    "samsung|samsung|SM-G985F|samsung/y2s/y2s:11/RP1A.200720.012/G985FXXU1ATH3:user/release-keys"
    "samsung|samsung|SM-G980F|samsung/x1s/x1s:11/RP1A.200720.012/G980FXXU1ATH3:user/release-keys"
    "samsung|samsung|SM-N975F|samsung/d2s/d2s:10/QP1A.190711.020/N975FXXU1ASGO:user/release-keys"
    "samsung|samsung|SM-N970F|samsung/d1/d1:10/QP1A.190711.020/N970FXXU1ASGO:user/release-keys"
    "samsung|samsung|SM-G975F|samsung/beyond2/beyond2:10/QP1A.190711.020/G975FXXU3BSKO:user/release-keys"
    "samsung|samsung|SM-G973F|samsung/beyond1/beyond1:10/QP1A.190711.020/G973FXXU3BSKO:user/release-keys"
    "samsung|samsung|SM-G970F|samsung/beyond0/beyond0:10/QP1A.190711.020/G970FXXU3BSKO:user/release-keys"
    "samsung|samsung|SM-F936B|samsung/q4q/q4q:12/SP1A.210812.016/F936BXXU1AVH9:user/release-keys"
    "samsung|samsung|SM-F721B|samsung/b4q/b4q:12/SP1A.210812.016/F721BXXU1AVH9:user/release-keys"
    "samsung|samsung|SM-A736B|samsung/a73xq/a73xq:12/SP1A.210812.016/A736BXXU1AVF3:user/release-keys"
    "samsung|samsung|SM-A546E|samsung/a54x/a54x:13/TP1A.220624.014/A546EXXU1AWD4:user/release-keys"
    "samsung|samsung|SM-A536E|samsung/a53x/a53x:12/SP1A.210812.016/A536EXXU2AVD7:user/release-keys"
    "samsung|samsung|SM-A528B|samsung/a52sxq/a52sxq:12/SP1A.210812.016/A528BXXU1CVG2:user/release-keys"
    "samsung|samsung|SM-A525F|samsung/a52/a52:11/RP1A.200720.012/A525FXXU1AUC5:user/release-keys"
    "samsung|samsung|SM-A336E|samsung/a33x/a33x:12/SP1A.210812.016/A336EXXU2AVF2:user/release-keys"
    "samsung|samsung|SM-A325F|samsung/a32/a32:11/RP1A.200720.012/A325FXXU1AUD4:user/release-keys"
    "samsung|samsung|SM-A235F|samsung/a23/a23:12/SP1A.210812.016/A235FXXU1AVD5:user/release-keys"
    "samsung|samsung|SM-A226B|samsung/a22x/a22x:11/RP1A.200720.012/A226BXXU1AUH1:user/release-keys"
    "samsung|samsung|SM-A135F|samsung/a13/a13:12/SP1A.210812.016/A135FXXU1AVF1:user/release-keys"
    "samsung|samsung|SM-A125F|samsung/a12/a12:11/RP1A.200720.012/A125FXXU1BUE3:user/release-keys"
    "samsung|samsung|SM-A047F|samsung/a04s/a04s:12/SP1A.210812.016/A047FXXU1AVH2:user/release-keys"
    "samsung|samsung|SM-M536B|samsung/m53x/m53x:12/SP1A.210812.016/M536BXXU1AVD6:user/release-keys"
    "samsung|samsung|SM-M526B|samsung/m52xq/m52xq:11/RP1A.200720.012/M526BXXU1AUJ2:user/release-keys"
    "samsung|samsung|SM-M336B|samsung/m33x/m33x:12/SP1A.210812.016/M336BXXU1AVD5:user/release-keys"
    "samsung|samsung|SM-M236B|samsung/m23x/m23x:12/SP1A.210812.016/M236BXXU1AVD5:user/release-keys"
    "samsung|samsung|SM-M127F|samsung/m12/m12:11/RP1A.200720.012/M127FXXU1BUD8:user/release-keys"
    "samsung|samsung|SM-E5260|samsung/m52xq/m52xq:11/RP1A.200720.012/E5260ZCU1AUJ2:user/release-keys"
    "Xiaomi|Xiaomi|2211133G|Xiaomi/fuxi_global/fuxi:13/TKQ1.221114.001/V14.0.1.0.TMCMIXM:user/release-keys"
    "Xiaomi|Xiaomi|2210132G|Xiaomi/nuwa_global/nuwa:13/TKQ1.221114.001/V14.0.1.0.TMBMIXM:user/release-keys"
    "Xiaomi|Xiaomi|2201123G|Xiaomi/cupid_global/cupid:13/TKQ1.220829.002/V14.0.1.0.TLCMIXM:user/release-keys"
    "Xiaomi|Xiaomi|2201122G|Xiaomi/zeus_global/zeus:13/TKQ1.220829.002/V14.0.1.0.TLBMIXM:user/release-keys"
    "Xiaomi|Xiaomi|21081111RG|Xiaomi/vili_global/vili:12/SKQ1.211006.001/V13.0.1.0.SKDMIXM:user/release-keys"
    "Xiaomi|Xiaomi|2107113SG|Xiaomi/agate_global/agate:12/SKQ1.211006.001/V13.0.1.0.SKTMIXM:user/release-keys"
    "Xiaomi|Xiaomi|M2102K1G|Xiaomi/star_global/star:12/SKQ1.211006.001/V13.0.3.0.SKAMIXM:user/release-keys"
    "Xiaomi|Xiaomi|M2011K2G|Xiaomi/venus_global/venus:12/SKQ1.211006.001/V13.0.1.0.SKBMIXM:user/release-keys"
    "Xiaomi|Xiaomi|M2007J20CG|Redmi/surya_global/surya:10/QKQ1.200628.002/V12.0.8.0.QJGMIXM:user/release-keys"
    "Xiaomi|Xiaomi|M2007J3SG|Xiaomi/apollo_global/apollo:11/RKQ1.200826.002/V12.5.1.0.RJDMIXM:user/release-keys"
    "Xiaomi|Xiaomi|M2007J1SC|Xiaomi/cas_global/cas:11/RKQ1.200826.002/V12.5.1.0.RJJMIXM:user/release-keys"
    "POCO|Xiaomi|23049PCD8G|POCO/marble_global/marble:13/TKQ1.221114.001/V14.0.1.0.TMRMIXM:user/release-keys"
    "POCO|Xiaomi|23013PC75G|POCO/moonstone_global/moonstone:13/TKQ1.221114.001/V14.0.1.0.TMSMIXM:user/release-keys"
    "POCO|Xiaomi|22101320G|POCO/sunstone_global/sunstone:13/TKQ1.221114.001/V14.0.1.0.TMTMIXM:user/release-keys"
    "POCO|Xiaomi|22041216G|POCO/x4pro_global/x4pro:12/SKQ1.211006.001/V13.0.1.0.SKCMIXM:user/release-keys"
    "POCO|Xiaomi|22011211G|POCO/munch_global/munch:12/SKQ1.211006.001/V13.0.3.0.SLMMIXM:user/release-keys"
    "POCO|Xiaomi|M2102J20SG|POCO/vayu_global/vayu:12/SKQ1.211006.001/V13.0.1.0.SJUMIXM:user/release-keys"
    "POCO|Xiaomi|M2012K11AG|POCO/alioth_global/alioth:12/SKQ1.211006.001/V13.0.2.0.SKHMIXM:user/release-keys"
    "POCO|Xiaomi|22021211RC|POCO/lmi_global/lmi:11/RKQ1.200826.002/V12.2.4.0.RJKMIXM:user/release-keys"
    "POCO|Xiaomi|M2010J19CG|POCO/citrus_global/citrus:10/QKQ1.200628.002/V12.0.8.0.QJFMIXM:user/release-keys"
    "Redmi|Xiaomi|23021RAAEG|Redmi/topaz_global/topaz:13/TKQ1.221114.001/V14.0.2.0.TMGMIXM:user/release-keys"
    "Redmi|Xiaomi|22101316G|Redmi/ruby_global/ruby:13/TKQ1.221114.001/V14.0.2.0.TMOEUXM:user/release-keys"
    "Redmi|Xiaomi|2201116SG|Redmi/veux_global/veux:12/SKQ1.211006.001/V13.0.2.0.SKCMIXM:user/release-keys"
    "Redmi|Xiaomi|2201117TY|Redmi/spes_global/spes:12/SKQ1.211006.001/V13.0.1.0.SKGMIXM:user/release-keys"
    "Redmi|Xiaomi|22011119UY|Redmi/selene_global/selene:12/SKQ1.211006.001/V13.0.1.0.SKUMIXM:user/release-keys"
    "Redmi|Xiaomi|2109119DG|Redmi/mona_global/mona:12/SKQ1.211006.001/V13.0.1.0.SKIMIXM:user/release-keys"
    "Redmi|Xiaomi|M2101K6G|Redmi/sweet_global/sweet:12/SKQ1.210908.001/V13.0.8.0.SKFMIXM:user/release-keys"
    "Redmi|Xiaomi|M2101K7AG|Redmi/rosemary_global/rosemary:12/SKQ1.210908.001/V13.0.4.0.SKWMIXM:user/release-keys"
    "Redmi|Xiaomi|M2101K9G|Redmi/mojito_global/mojito:12/SKQ1.210908.001/V13.0.4.0.SKGMIXM:user/release-keys"
    "Redmi|Xiaomi|M2003J15SC|Redmi/merlin_global/merlin:11/RP1A.200720.011/V12.5.1.0.RJOMIXM:user/release-keys"
    "Redmi|Xiaomi|M2004J19C|Redmi/lancelot_global/lancelot:10/QP1A.190711.020/V12.0.1.0.QJCINXM:user/release-keys"
    "Redmi|Xiaomi|M2006C3MG|Redmi/angelica_global/angelica:10/QP1A.190711.020/V12.0.10.0.QCRMIXM:user/release-keys"
    "Redmi|Xiaomi|M2006C3LG|Redmi/dandelion_global/dandelion:10/QP1A.190711.020/V12.0.11.0.QCDMIXM:user/release-keys"
    "google|google|Pixel 7 Pro|google/cheetah/cheetah:13/TQ1A.221205.011/9126201:user/release-keys"
    "google|google|Pixel 7|google/panther/panther:13/TQ1A.221205.011/9126201:user/release-keys"
    "google|google|Pixel 6 Pro|google/raven/raven:13/TP1A.220624.021/8877034:user/release-keys"
    "google|google|Pixel 6|google/oriole/oriole:13/TP1A.220624.021/8877034:user/release-keys"
    "google|google|Pixel 6a|google/bluejay/bluejay:13/TP1A.220624.021/8877034:user/release-keys"
    "google|google|Pixel 5|google/redfin/redfin:13/TP1A.220624.014/8819526:user/release-keys"
    "google|google|Pixel 4a (5G)|google/bramble/bramble:13/TP1A.220624.014/8819526:user/release-keys"
    "google|google|Pixel 5a|google/barbet/barbet:13/TP1A.220624.014/8819526:user/release-keys"
    "google|google|Pixel 4 XL|google/coral/coral:12/SP2A.220505.002/8353555:user/release-keys"
    "google|google|Pixel 4|google/flame/flame:12/SP2A.220505.002/8353555:user/release-keys"
    "google|google|Pixel 4a|google/sunfish/sunfish:12/SP2A.220505.002/8353555:user/release-keys"
    "google|google|Pixel 3a XL|google/bonito/bonito:12/SP2A.220505.002/8353555:user/release-keys"
    "google|google|Pixel 3a|google/sargo/sargo:12/SP2A.220505.002/8353555:user/release-keys"
    "google|google|Pixel 3 XL|google/crosshatch/crosshatch:12/SP1A.210812.015/7679548:user/release-keys"
    "google|google|Pixel 3|google/blueline/blueline:12/SP1A.210812.015/7679548:user/release-keys"
    "OPPO|OPPO|CPH2437|OPPO/CPH2437/OPH2437:13/TP1A.220905.001/1675850901:user/release-keys"
    "OPPO|OPPO|CPH2451|OPPO/CPH2451/OPH2451:13/TP1A.220905.001/1676523924:user/release-keys"
    "OPPO|OPPO|CPH2357|OPPO/CPH2357/OPH2357:12/SP1A.210812.016/1660230230:user/release-keys"
    "OPPO|OPPO|CPH2307|OPPO/CPH2307/OPH2307:12/SKQ1.211019.001/1640105050:user/release-keys"
    "OPPO|OPPO|CPH2305|OPPO/CPH2305/OPH2305:12/SKQ1.211019.001/1640105050:user/release-keys"
    "OPPO|OPPO|CPH2173|OPPO/CPH2173/OPH2173:12/SKQ1.211019.001/1640105050:user/release-keys"
    "OPPO|OPPO|CPH2249|OPPO/CPH2249/OPH2249:11/RP1A.200720.011/1620815467:user/release-keys"
    "OPPO|OPPO|CPH2251|OPPO/CPH2251/OPH2251:11/RP1A.200720.011/1620815467:user/release-keys"
    "OPPO|OPPO|CPH2219|OPPO/CPH2219/OPH2219:11/RP1A.200720.011/1620815467:user/release-keys"
    "OPPO|OPPO|CPH2239|OPPO/CPH2239/OPH2239:11/RP1A.200720.011/1620815467:user/release-keys"
    "OPPO|OPPO|CPH2145|OPPO/CPH2145/OPH2145:11/RP1A.200720.011/1620815467:user/release-keys"
    "OPPO|OPPO|CPH2127|OPPO/CPH2127/OPH2127:11/RP1A.200720.011/1620815467:user/release-keys"
    "OPPO|OPPO|CPH2083|OPPO/CPH2083/OPH2083:11/RP1A.200720.011/1620815467:user/release-keys"
    "OPPO|OPPO|CPH2113|OPPO/CPH2113/OPH2113:11/RP1A.200720.011/1620815467:user/release-keys"
    "OPPO|OPPO|CPH2065|OPPO/CPH2065/OPH2065:11/RP1A.200720.011/1620815467:user/release-keys"
    "OPPO|OPPO|CPH2009|OPPO/CPH2009/OPH2009:11/RP1A.200720.011/1620815467:user/release-keys"
    "OPPO|OPPO|CPH2023|OPPO/CPH2023/OPH2023:10/QKQ1.191222.002/1598426543:user/release-keys"
    "OPPO|OPPO|CPH1969|OPPO/CPH1969/OPH1969:10/QKQ1.191222.002/1598426543:user/release-keys"
    "OPPO|OPPO|CPH1917|OPPO/CPH1917/OPH1917:10/QKQ1.191222.002/1598426543:user/release-keys"
    "OPPO|OPPO|CPH1907|OPPO/CPH1907/OPH1907:10/QKQ1.191222.002/1598426543:user/release-keys"
    "vivo|vivo|V2219|vivo/V2219/V2219:13/TP1A.220624.014/compiler08252243:user/release-keys"
    "vivo|vivo|V2202|vivo/V2202/V2202:13/TP1A.220624.014/compiler08252243:user/release-keys"
    "vivo|vivo|V2158|vivo/V2158/V2158:12/SP1A.210812.003/compiler03161830:user/release-keys"
    "vivo|vivo|V2142|vivo/V2142/V2142:12/SP1A.210812.003/compiler03161830:user/release-keys"
    "vivo|vivo|V2130|vivo/V2130/V2130:12/SP1A.210812.003/compiler03161830:user/release-keys"
    "vivo|vivo|V2109|vivo/V2109/V2109:11/RP1A.200720.012/compiler08252243:user/release-keys"
    "vivo|vivo|V2050|vivo/V2050/V2050:11/RP1A.200720.012/compiler01221750:user/release-keys"
    "vivo|vivo|V2043|vivo/2043/2043:11/RP1A.200720.012/compiler05211956:user/release-keys"
    "vivo|vivo|V2035|vivo/V2035/V2035:11/RP1A.200720.012/compiler05211956:user/release-keys"
    "vivo|vivo|V2027|vivo/V2027/V2027:11/RP1A.200720.012/compiler05211956:user/release-keys"
    "vivo|vivo|V2026|vivo/V2026/V2026:11/RP1A.200720.012/compiler05211956:user/release-keys"
    "vivo|vivo|V2025|vivo/2025/2025:11/RP1A.200720.012/compiler08252243:user/release-keys"
    "vivo|vivo|V1938|vivo/1938/1938:10/QP1A.190711.020/compiler08031853:user/release-keys"
    "vivo|vivo|V1935|vivo/1935/1935:10/QP1A.190711.020/compiler08031853:user/release-keys"
    "vivo|vivo|V1919|vivo/1919/1919:10/QP1A.190711.020/compiler08031853:user/release-keys"
    "vivo|vivo|V1907|vivo/1907/1907:10/QP1A.190711.020/compiler08031853:user/release-keys"
    "realme|realme|RMX3301|realme/RMX3301/RMX3301:13/TP1A.220905.001/1676882294:user/release-keys"
    "realme|realme|RMX3561|realme/RMX3561/RMX3561:12/SP1A.210812.016/1652432223:user/release-keys"
    "realme|realme|RMX3392|realme/RMX3392/RMX3392:12/SP1A.210812.016/1652432223:user/release-keys"
    "realme|realme|RMX3370|realme/RMX3370/RMX3370:12/SP1A.210812.016/1648197365:user/release-keys"
    "realme|realme|RMX3363|realme/RMX3363/RMX3363:12/SP1A.210812.016/1652432223:user/release-keys"
    "realme|realme|RMX3031|realme/RMX3031/RMX3031:11/RP1A.200720.011/1618386345:user/release-keys"
    "realme|realme|RMX3241|realme/RMX3241/RMX3241:11/RP1A.200720.011/1626337852:user/release-keys"
    "realme|realme|RMX3191|realme/RMX3191/RMX3191:11/RP1A.200720.011/1626337852:user/release-keys"
    "realme|realme|RMX3195|realme/RMX3195/RMX3195:11/RP1A.200720.011/1626337852:user/release-keys"
    "realme|realme|RMX2202|realme/RMX2202/RMX2202:11/RP1A.200720.011/1626337852:user/release-keys"
    "realme|realme|RMX2170|realme/RMX2170/RMX2170:11/RP1A.200720.011/1602737666:user/release-keys"
    "realme|realme|RMX2151|realme/RMX2151/RMX2151:11/RP1A.200720.011/1602737666:user/release-keys"
    "realme|realme|RMX2111|realme/RMX2111/RMX2111:10/QKQ1.191222.002/1602737666:user/release-keys"
    "realme|realme|RMX2001|realme/RMX2001/RMX2001:10/QKQ1.191222.002/1602737666:user/release-keys"
    "realme|realme|RMX1931|realme/RMX1931/RMX1931:10/QKQ1.190918.001/1584067325:user/release-keys"
    "realme|realme|RMX1921|realme/RMX1921/RMX1921:10/QKQ1.190918.001/1584067325:user/release-keys"
    "realme|realme|RMX1911|realme/RMX1911/RMX1911:10/QKQ1.190918.001/1584067325:user/release-keys"
    "realme|realme|RMX1851|realme/RMX1851/RMX1851:10/QKQ1.190918.001/1584067325:user/release-keys"
    "OnePlus|OnePlus|CPH2413|OnePlus/OnePlus10T/OnePlus10T:13/TP1A.220905.001/S.202302241645:user/release-keys"
    "OnePlus|OnePlus|NE2213|OnePlus/OnePlus10Pro_EEA/OnePlus10Pro:12/SKQ1.211113.001/NE2213_11_A.13:user/release-keys"
    "OnePlus|OnePlus|LE2123|OnePlus/OnePlus9Pro_EEA/OnePlus9Pro:12/SKQ1.210216.001/R.202203301646:user/release-keys"
    "OnePlus|OnePlus|LE2113|OnePlus/OnePlus9_EEA/OnePlus9:12/SKQ1.210216.001/R.202203301646:user/release-keys"
    "OnePlus|OnePlus|KB2003|OnePlus/OnePlus8T_EEA/OnePlus8T:11/RP1A.201005.001/2011132200:user/release-keys"
    "OnePlus|OnePlus|IN2023|OnePlus/OnePlus8Pro_EEA/OnePlus8Pro:11/RP1A.201005.001/2011132200:user/release-keys"
    "OnePlus|OnePlus|IN2013|OnePlus/OnePlus8_EEA/OnePlus8:11/RP1A.201005.001/2011132200:user/release-keys"
    "OnePlus|OnePlus|HD1903|OnePlus/OnePlus7T_EEA/OnePlus7T:11/RP1A.201005.001/2011132200:user/release-keys"
    "OnePlus|OnePlus|HD1913|OnePlus/OnePlus7TPro_EEA/OnePlus7TPro:11/RP1A.201005.001/2011132200:user/release-keys"
    "OnePlus|OnePlus|GM1913|OnePlus/OnePlus7Pro_EEA/OnePlus7Pro:11/RP1A.201005.001/2011132200:user/release-keys"
    "OnePlus|OnePlus|GM1903|OnePlus/OnePlus7_EEA/OnePlus7:11/RP1A.201005.001/2011132200:user/release-keys"
    "OnePlus|OnePlus|AC2003|OnePlus/Nord_EEA/Nord:11/RP1A.201005.001/2011132200:user/release-keys"
    "OnePlus|OnePlus|BE2029|OnePlus/NordN10_EEA/NordN10:11/RP1A.201005.001/2011132200:user/release-keys"
    "OnePlus|OnePlus|BE2026|OnePlus/NordN100_EEA/NordN100:11/RP1A.201005.001/2011132200:user/release-keys"
    "asus|asus|ASUS_AI2202|asus/WW_AI2202/ASUS_AI2202:13/TKQ1.220829.002/33.0804.2060.113:user/release-keys"
    "asus|asus|ASUS_AI2201|asus/WW_AI2201/ASUS_AI2201:13/TKQ1.220829.002/33.0804.2060.113:user/release-keys"
    "asus|asus|ASUS_I005DA|asus/WW_I005D/ASUS_I005D:12/SKQ1.211006.001/18.0840.2109.176:user/release-keys"
    "asus|asus|ASUS_I003D|asus/WW_I003D/ASUS_I003D:11/RKQ1.201022.002/17.0823.2008.78:user/release-keys"
    "asus|asus|ASUS_I001DC|asus/WW_I001D/ASUS_I001D:10/QKQ1.190825.002/16.0631.1910.35:user/release-keys"
    "asus|asus|ASUS_I001WD|asus/WW_I01WD/ASUS_I01WD:11/RKQ1.201022.002/18.0610.2106.142:user/release-keys"
    "asus|asus|ASUS_X01BDA|asus/WW_X01BD/ASUS_X01BD:10/QKQ1.191002.002/17.2017.2006.429:user/release-keys"
    "asus|asus|ASUS_X00TD|asus/WW_X00TD/ASUS_X00TD:9/PKQ1.180904.001/16.2017.2005.082:user/release-keys"
    "Sony|Sony|XQ-CT54|Sony/XQ-CT54_EEA/XQ-CT54:13/TKQ1.220807.001/64.1.A.0.869:user/release-keys"
    "Sony|Sony|XQ-CQ54|Sony/XQ-CQ54_EEA/XQ-CQ54:13/TKQ1.220807.001/64.1.A.0.869:user/release-keys"
    "Sony|Sony|XQ-BC52|Sony/XQ-BC52_EEA/XQ-BC52:12/SKQ1.211006.001/61.1.A.4.78:user/release-keys"
    "Sony|Sony|XQ-BB52|Sony/XQ-BB52_EEA/XQ-BB52:12/SKQ1.211006.001/61.1.A.4.78:user/release-keys"
    "Sony|Sony|XQ-AT51|Sony/XQ-AT51_EEA/XQ-AT51:11/RP1A.200720.012/58.1.A.5.530:user/release-keys"
    "Sony|Sony|XQ-AS52|Sony/XQ-AS52_EEA/XQ-AS52:11/RP1A.200720.012/58.1.A.5.530:user/release-keys"
    "Sony|Sony|J9210|Sony/J9210_EEA/J9210:11/RP1A.200720.012/55.2.A.4.332:user/release-keys"
    "Sony|Sony|J9110|Sony/J9110_EEA/J9110:11/RP1A.200720.012/55.2.A.4.332:user/release-keys"
    "Infinix|Infinix|X670|Infinix/X670-GL/Infinix-X670:12/SP1A.210812.016/220719V453:user/release-keys"
    "Infinix|Infinix|X663|Infinix/X663-GL/Infinix-X663:11/RP1A.200720.011/211230V350:user/release-keys"
    "Infinix|Infinix|X6817|Infinix/X6817-GL/Infinix-X6817:11/RP1A.200720.011/220110V500:user/release-keys"
    "Infinix|Infinix|X695|Infinix/X695-GL/Infinix-X695:11/RP1A.200720.011/210823V367:user/release-keys"
    "Infinix|Infinix|X693|Infinix/X693-GL/Infinix-X693:11/RP1A.200720.011/210823V367:user/release-keys"
    "Infinix|Infinix|X688B|Infinix/X688B-GL/Infinix-X688B:10/QP1A.190711.020/210329V368:user/release-keys"
    "TECNO|TECNO|AD8|TECNO/AD8-GL/TECNO-AD8:12/SP1A.210812.016/220719V453:user/release-keys"
    "TECNO|TECNO|CI6|TECNO/CI6-GL/TECNO-CI6:11/RP1A.200720.011/210816V298:user/release-keys"
    "TECNO|TECNO|CG6|TECNO/CG6-GL/TECNO-CG6:11/RP1A.200720.011/210629V392:user/release-keys"
    "TECNO|TECNO|LE7|TECNO/LE7-GL/TECNO-LE7:11/RP1A.200720.011/210816V298:user/release-keys"
    "Motorola|Motorola|XT2201-3|motorola/rogue_global/rogue:12/S1SC32.52-26/186a8:user/release-keys"
    "Motorola|Motorola|XT2125-4|motorola/nio_reteu/nio:11/RRN31.Q3-1-11-2/3067f:user/release-keys"
    "Motorola|Motorola|XT2135-2|motorola/pstar_reteu/pstar:12/S1RA32.41-20-16/36423:user/release-keys"
    "Motorola|Motorola|XT2063-3|motorola/edge_global/edge:11/RPD31.140-9-2/6920f:user/release-keys"
    "Motorola|Motorola|XT2019-1|motorola/doha_global/doha:10/QPF30.130-15-7/4955f:user/release-keys"
    "Huawei|Huawei|ELS-NX9|HUAWEI/ELS-NX9/ELS-NX9:10/HUAWEIELS-NX9/10.1.0.176C432:user/release-keys"
    "Huawei|Huawei|VOG-L29|HUAWEI/VOG-L29/VOG-L29:10/HUAWEIVOG-L29/10.1.0.133C432:user/release-keys"
    "Huawei|Huawei|ANA-NX9|HUAWEI/ANA-NX9/ANA-NX9:10/HUAWEIANA-NX9/10.1.0.176C432:user/release-keys"
    "Huawei|Huawei|MAR-LX1A|HUAWEI/MAR-LX1A/MAR-LX1A:10/HUAWEIMAR-LX1A/10.0.0.255C432:user/release-keys"
    "Huawei|Huawei|POT-LX1|HUAWEI/POT-LX1/POT-LX1:10/HUAWEIPOT-LX1/10.0.0.255C432:user/release-keys"
    "samsung|samsung|SM-G781B|samsung/r8q/r8q:13/TP1A.220624.014/G781BXXU4HWD1:user/release-keys"
    "samsung|samsung|SM-X700|samsung/gts8/gts8:13/TP1A.220624.014/X700XXU3BWD1:user/release-keys"
    "Xiaomi|Xiaomi|M2103K19G|Xiaomi/camellian_global/camellian:11/RP1A.200720.011/V12.5.4.0.RKSMIXM:user/release-keys"
    "Xiaomi|Xiaomi|22071212AG|Xiaomi/diting_global/diting:13/TKQ1.220829.002/V14.0.1.0.TLFMIXM:user/release-keys"
    "OnePlus|OnePlus|MT2111|OnePlus/OnePlus9RT_EEA/OnePlus9RT:12/SKQ1.210216.001/R.202203301646:user/release-keys"
    "realme|realme|RMX3085|realme/RMX3085/RMX3085:11/RP1A.200720.011/1626337852:user/release-keys"
    "vivo|vivo|V2055|vivo/V2055/V2055:12/SP1A.210812.003/compiler03161830:user/release-keys"
)

HISTORY_FILE="/root/.used_devices"

# 3. FUNGSI CEK KONEKSI (ANTI BENGONG/STUCK)
function ensure_connect() {
    echo ">>> [CONNECT] Memeriksa sambungan ADB..."
    adb disconnect localhost:5555 > /dev/null 2>&1
    sleep 1
    adb connect localhost:5555 > /dev/null 2>&1
    
    MAX_RETRY=10
    for (( j=1; j<=MAX_RETRY; j++ )); do
        STATE=$(adb -s localhost:5555 get-state 2>/dev/null)
        if [ "$STATE" == "device" ]; then
            return 0
        fi
        echo -n "."
        sleep 2
        adb connect localhost:5555 > /dev/null 2>&1
    done
    echo ">>> [WARNING] Koneksi belum stabil..."
}

# 4. STATISTIK
TOTAL_DEVICES=${#DEVICES[@]}
[ ! -f "$HISTORY_FILE" ] && touch "$HISTORY_FILE"
USED_COUNT=$(wc -l < "$HISTORY_FILE")
REMAINING=$((TOTAL_DEVICES - USED_COUNT))

echo "=============================================="
echo ">>> REDROID GEN (V8 - FINAL VERBOSE)"
echo ">>> Total Device: $TOTAL_DEVICES | Sisa: $REMAINING"
echo "=============================================="

if [ "$REMAINING" -le 0 ]; then
    echo "[STOP] DB HABIS. Reset: rm $HISTORY_FILE"; exit 1
fi

# 5. PILIH DEVICE
while true; do
    RANDOM_INDEX=$((RANDOM % TOTAL_DEVICES))
    IFS='|' read -r TMP_BRAND TMP_MANUF TMP_MODEL TMP_FINGER <<< "${DEVICES[$RANDOM_INDEX]}"
    if ! grep -Fxq "$TMP_MODEL" "$HISTORY_FILE"; then
        BRAND=$TMP_BRAND; MANUF=$TMP_MANUF; MODEL=$TMP_MODEL; FINGERPRINT=$TMP_FINGER
        echo "$MODEL" >> "$HISTORY_FILE"
        break
    fi
done

# 6. GENERATE DATA
GEN_IMEI=$(shuf -i 350000000000000-359999999999999 -n 1)
GEN_MAC=$(printf '02:%02x:%02x:%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
RAND_SUFFIX=$(shuf -i 100000000-999999999 -n 1)
GEN_PHONE="+628${RAND_SUFFIX}"
GEN_SERIAL=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
MY_IP=$(curl -s ifconfig.me || echo "Offline")

echo ">>> NEW IDENTITY:"
echo "----------------------------------------------"
echo "Brand        : $BRAND"
echo "Model        : $MODEL"
echo "Serial       : $GEN_SERIAL"
echo "Phone        : $GEN_PHONE"
echo "VPS IP       : $MY_IP"
echo "----------------------------------------------"

# 7. MEMBERSIHKAN CONTAINER
echo ">>> [CLEANING] Membersihkan sisa container..."
sudo docker rm -f android_11 > /dev/null 2>&1
sudo rm -rf ~/data_11 && mkdir -p ~/data_11
echo "   + Data reset selesai."

# ==========================================================
#   DOWNLOAD IMAGE DULU (AGAR TIDAK NUMPUK SAAT RUN)
# ==========================================================
echo ">>> [DOWNLOAD] Memastikan Image Redroid tersedia..."
sudo docker pull redroid/redroid:11.0.0-latest

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

# 8. JALANKAN CONTAINER
echo ">>> [STARTING] Menjalankan Android 11..."
sudo docker run -itd \
    --cpus="$CONTAINER_CPU" \
    --memory="${CONTAINER_RAM}m" \
    --memory-swap="-1" \
    --privileged \
    --restart=always \
    -v ~/data_11:/data \
    -p 5555:5555 \
    --name android_11 \
    redroid/redroid:11.0.0-latest \
    androidboot.redroid_width=720 \
    androidboot.redroid_height=1280 \
    androidboot.redroid_dpi=320 \
    androidboot.redroid_gpu_mode=guest \
    androidboot.redroid_mac="$GEN_MAC" \
    androidboot.serialno="$GEN_SERIAL" \
    ro.product.brand="$BRAND" \
    ro.product.model="$MODEL" \
    ro.product.manufacturer="$MANUF" \
    ro.build.fingerprint="$FINGERPRINT" \
    ro.ril.oem.imei="$GEN_IMEI" \
    ro.ril.oem.phone_number="$GEN_PHONE" \
    gsm.sim.msisdn="$GEN_PHONE" \
    ro.adb.secure=0 \
    ro.secure=0 \
    ro.debuggable=1 > /dev/null

if [ $? -eq 0 ]; then
    echo ">>> [SUKSES] Container Berjalan! ID: $(sudo docker ps -q -f name=android_11)"
else
    echo ">>> [FATAL ERROR] Gagal menjalankan Docker!"
    exit 1
fi
echo "=============================================="

# 9. JEDA WAJIB (10 DETIK)
echo ">>> [WAIT] Menunggu booting (10 detik)..."
sleep 10

# 10. KONEKSI & INJEKSI
ensure_connect
echo ">>> [OK] Terhubung ke ADB!"
echo ""

echo ">>> [INJECT] Menyuntikkan Nomor HP ($GEN_PHONE)..."
adb -s localhost:5555 wait-for-device

adb -s localhost:5555 shell setprop gsm.sim.operator.alpha "Telkomsel"
adb -s localhost:5555 shell setprop gsm.sim.operator.numeric "51010"
adb -s localhost:5555 shell setprop gsm.sim.state "READY"
adb -s localhost:5555 shell setprop gsm.current.phone-number "$GEN_PHONE"
adb -s localhost:5555 shell setprop gsm.sim.msisdn "$GEN_PHONE"
adb -s localhost:5555 shell setprop line1.number "$GEN_PHONE"

# Kill Phone Process (Fix Ampuh)
adb -s localhost:5555 shell "pkill -f com.android.phone || killall com.android.phone"
adb -s localhost:5555 shell "killall rild" >/dev/null 2>&1

echo ">>> [REFRESH] Menunggu restart sinyal (5 detik)..."
sleep 5

ensure_connect

# Double Inject
adb -s localhost:5555 shell setprop gsm.sim.msisdn "$GEN_PHONE"
adb -s localhost:5555 shell setprop line1.number "$GEN_PHONE"

echo ">>> [OK] Phone Process Restarted!"

# 11. CEK HASIL
RESULT=$(adb -s localhost:5555 shell getprop gsm.sim.msisdn)
echo ">>> [VERIFIKASI] Status Property: $RESULT"

# 12. INSTALL DUKU
if [ -f "/root/duku.apk" ]; then
    echo ">>> [INSTALL] Sedang menginstall Duku Live..."
    ensure_connect
    timeout 60 adb -s localhost:5555 install -r /root/duku.apk
    if [ $? -eq 0 ]; then
        echo ">>> [SUKSES] Duku Live Terpasang!"
    else
        echo ">>> [INFO] Gagal Install. Coba manual."
    fi
fi
echo "=============================================="
