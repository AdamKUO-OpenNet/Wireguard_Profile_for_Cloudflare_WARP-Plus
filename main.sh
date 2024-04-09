#!/bin/sh

# Define file names
ACCOUNT_FILE="wgcf-account.toml"
PROFILE_FILE="wgcf-profile.conf"

# Define functions
red() {
    echo -e "\033[31m\033[01m$1\033[0m"
}

green() {
    echo -e "\033[32m\033[01m$1\033[0m"
}

yellow() {
    echo -e "\033[33m\033[01m$1\033[0m"
}

run_wgcf() {
    if ! ./wgcf "$@"; then
        red "wgcf command failed: wgcf $*"
        exit 1
    fi
}

# Main script
clear
rm -f $ACCOUNT_FILE $PROFILE_FILE
echo | run_wgcf register
chmod +x $ACCOUNT_FILE

clear
yellow "Wireguard Profile generator for Cloudflare WARP Plus "
echo ""
echo -e " ${GREEN} ${PLAIN} WARP Plus for Sporty"
echo ""

yellow "Please fetch your own WARP+ License Key - (XXXXXXXX-XXXXXXXX-XXXXXXXX)"
green  "Mac: CloudFlare WARP APP → Setting Gear → Preference  → Account → License Key"
green  "Mobile: Cloudflare 1.1.1.1 APP → Menu → Account → Key"
echo ""
red "Please make sure your account type is !!Sporty WARP+!!"
echo ""
read -rp "Please enter your WARP+ License Key:" warpkey
until [[ $warpkey =~ ^[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}$ ]]; do
    red "The Key entered is not match the WARP license pattern！"
    read -rp "Please enter your WARP+ License Key: " warpkey
done
sed -i "s/license_key.*/license_key = \"$warpkey\"/g" $ACCOUNT_FILE
read -rp "Please setup the device name for this Profile or leave empty for default: " devicename
if [[ -n $devicename ]]; then
    run_wgcf update --name $(echo $devicename | sed s/[[:space:]]/_/g)
else
    run_wgcf update
fi
echo "Generate the Wireguard Profile""
run_wgcf generate

chmod +x $PROFILE_FILE

#clear
green "Profile generated successfully by WGCF！"
yellow "Your Wireguard Profile of Sporty WARP+："
red "$(cat $PROFILE_FILE)"
echo ""
yellow "Your QR Code of the Wireguard Profile："
qrencode -t ansiutf8 < $PROFILE_FILE

# Remove the generated files
rm -f $ACCOUNT_FILE $PROFILE_FILE
