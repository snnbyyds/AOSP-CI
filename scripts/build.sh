#!/bin/bash

echo “Source Vars”
export USE_CCACHE=1
export CCACHE_SIZE=60G
export ALLOW_MISSING_DEPENDENCIES=true

# A Function to Send Posts to Telegram
telegram_message() {
	curl -s -X POST "https://api.telegram.org/bot${TG_TOKEN}/sendMessage" \
	-d chat_id="${TG_CHAT_ID}" \
	-d parse_mode="HTML" \
	-d text="$1"
}

# Change to the Source Directry
cd ~/android


# Set-up ccache
if [ -z "$CCACHE_SIZE" ]; then
    ccache -M 60G
else
    ccache -M ${CCACHE_SIZE}
fi

echo '[DEBUG]rm -rf  system/sepolicy/prebuilts/api/33.0/private/property.te'
rm -rf  system/sepolicy/prebuilts/api/33.0/private/property.te
echo '[DEBUG]cp -r system/sepolicy/private/property.te system/sepolicy/prebuilts/api/33.0/private/'
cp -r system/sepolicy/private/property.te system/sepolicy/prebuilts/api/33.0/private/
ls system/sepolicy/prebuilts/api/33.0/private/

# Prepare the Build Environment
cd ~/android
source build/envsetup.sh
export ROOMSERVICE_BRANCHES=snow

echo "extracting proprietary"
mkdir ~/android/system_dump/
cd ~/android/system_dump/
git clone -b cust https://github.com/snnbyyds/vendor_oneplus.git ~/vendor_oneplus
mkdir system/
mkdir system/vendor/
mkdir system/odm/
mkdir system/product/
mkdir system/system_ext/
cp -r ~/vendor_oneplus/sdm845-common/proprietary/system .
cp -r ~/vendor_oneplus/sdm845-common/proprietary/system_ext system/
cp -r ~/vendor_oneplus/sdm845-common/proprietary/vendor system/
cp -r ~/vendor_oneplus/sdm845-common/proprietary/product system/
cp -r ~/vendor_oneplus/fajita/proprietary/odm system/
cp -r ~/vendor_oneplus/fajita/proprietary/vendor system/
cd ~/android/device/oneplus/fajita
./extract-files.sh ~/android/system_dump/

cd ~/android
lunch evolution_fajita-eng

# Build!
echo 'Start Build!'
mka evolution -j16

# Exit
exit 0
