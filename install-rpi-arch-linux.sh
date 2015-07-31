#!/bin/bash

set -e
set -u
set -o pipefail

usage() {
    echo "Usage: $0 DEVICE HOSTNAME WLAN-NAME WLAN-PASSWORD"
    echo "Example: $0 /dev/sdX mypi myap myapppassword"
    exit 1
}

[ $# -ne 4 ] && { usage; }

DEVICE="$1"
HOSTNAME="$2"
WLAN_NAME="$3"
WLAN_PASSWORD="$4"

WLAN_KEY=$(wpa_passphrase "$WLAN_NAME" "$WLAN_PASSWORD" \
    | grep -v "#psk=" | grep "psk=" | cut -d "=" -f 2)

if [ ! -e "$DEVICE" ]; then
    echo "Device $DEVICE not found!"
    echo "Give a valid device (e.g. /dev/sdX)"
    exit 2
fi

echo "Flashing device $DEVICE and setting hostname to $HOSTNAME"

TMP_DIR=$(mktemp -d)
echo "Temp directory: $TMP_DIR"
cd "$TMP_DIR"

cleanup() {
    echo "Cleaning up $TMP_DIR"
    rm -rf "$TMP_DIR"
}

trap cleanup 0

echo "Creating partitions"
echo "o
p
n
p
1

+100M
p
t
c
n
p
2


p
w
w
" | fdisk "$DEVICE"

echo "Creating boot filesystem"
mkfs.vfat "$DEVICE"1
mkdir boot
mount "$DEVICE"1 boot

echo "Creating root filesystem"
mkfs.ext4 "$DEVICE"2
mkdir root
mount "$DEVICE"2 root

echo "Copying base image"
wget http://archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz
tar -xf ArchLinuxARM-rpi-latest.tar.gz -C root
sync

echo "Copying netctl profiles"
cat > root/etc/netctl/wlan0-"${WLAN_NAME}" << EOF
Description='WLAN profile for ${WLAN_NAME}'
Interface=wlan0
Connection=wireless
Security=wpa
ESSID=${WLAN_NAME}
IP=dhcp
Key=\"${WLAN_KEY}
ForceConnect=yes
TimeoutDHCP=40
EOF

echo "Creating systemd service for netctl profile"
cat > "root/etc/systemd/system/netctl@wlan0\x2d${WLAN_NAME}.service" << EOF
.include /usr/lib/systemd/system/netctl@.service

[Unit]
Description=WLAN profile for ${WLAN_NAME}
BindsTo=sys-subsystem-net-devices-wlan0.device
After=sys-subsystem-net-devices-wlan0.device
EOF

echo "Enabling WLAN netctl profile at startup"
pushd root/etc/systemd/system/multi-user.target.wants
ln -s "../netctl@wlan0\x2d${WLAN_NAME}.service" "netctl@wlan0\x2d${WLAN_NAME}.service"
popd

echo "Disabling powersave on WLAN in udev"
cat > root/etc/udev/rules.d/70-wifi-powersave.rules << EOF
ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlan*", RUN+="/usr/bin/iw dev %k set power_save off"
EOF

echo "Copying boot files to boot partition"
mv root/boot/* boot

echo "Setting hostname to $HOSTNAME"
echo "$HOSTNAME" > root/etc/hostname

if [ -f "$HOME/.ssh/id_rsa.pub" ]; then
    echo "Copying SSH public key"
    mkdir -p root/root/.ssh
    cat "$HOME/.ssh/id_rsa.pub" >> root/root/.ssh/authorized_keys
fi

echo "Unmounting partitions"
sync
umount boot root
