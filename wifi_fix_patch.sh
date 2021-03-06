#!/bin/bash

function extract_wifi_fix_patch {
if [ "${SEPARATE_WLAN_MODULE}" == "y" ]; then
logb "\t\tExtracting Wifi fix patch..."
cat <<WIFI_F > ${PATCH_DIR}/wifi_fix.patch
diff --git a/kernel/samsung/msm8916/arch/arm/configs/msm8916_sec_defconfig b/kernel/samsung/msm8916/arch/arm/configs/msm8916_sec_defconfig
index 04ad01c474e3..285afd1a4c9e 100644
--- a/kernel/samsung/msm8916/arch/arm/configs/msm8916_sec_defconfig
+++ b/kernel/samsung/msm8916/arch/arm/configs/msm8916_sec_defconfig
@@ -718,7 +718,7 @@ CONFIG_SECCOMP=y
 # Qualcomm Atheros Prima WLAN module
 #
 # CONFIG_PRIMA_WLAN is not set
-CONFIG_PRONTO_WLAN=y
+CONFIG_PRONTO_WLAN=m
 CONFIG_PRIMA_WLAN_BTAMP=n
 CONFIG_PRIMA_WLAN_LFR=y
 CONFIG_PRIMA_WLAN_OKC=y
WIFI_F
fi
}

PATCH_FUNCTIONS=("${PATCH_FUNCTIONS[@]}" "extract_wifi_fix_patch")
