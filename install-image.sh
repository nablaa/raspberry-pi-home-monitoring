#!/bin/bash

set -e
set -u

usage() {
    echo "Usage: $0 DEVICE HOSTNAME"
    echo "Example: $0 /dev/sdX mypi"
    exit 1
}

[ $# -ne 2 ] && { usage; }

DEVICE="$1"
HOSTNAME="$2"

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

echo "Setting hostname to $HOSTNAME"
echo "$HOSTNAME" > root/etc/hostname

echo "Unmounting partitions"
sync
umount boot root
