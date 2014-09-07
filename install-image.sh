#!/bin/bash

set -e
set -u

DEVICE="$1"
ls "$DEVICE"

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
cat > root/etc/netctl/wlan0-gamma << EOF
Description='WLAN profile for myap'
Interface=wlan0
Connection=wireless
Security=wpa
ESSID=myap
IP=dhcp
Key=myap-password
ForceConnect=yes
TimeoutDHCP=40
EOF

echo "Adding netctl profile to systemd"
pushd root/etc/systemd/system/multi-user.target.wants
ln -s ../../../../usr/lib/systemd/system/netctl-auto@.service netctl-auto@wlan0.service
popd

echo "Disabling powersave on WLAN in udev"
cat > root/etc/udev/rules.d/70-wifi-powersave.rules << EOF
ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlan*", RUN+="/usr/bin/iw dev %k set power_save off"
EOF

echo "Copying boot files to boot partition"
mv root/boot/* boot

echo "Unmounting partitions"
sync
umount boot root
