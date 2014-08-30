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

echo "Copying boot files to boot partition"
mv root/boot/* boot

echo "Unmounting partitions"
sync
umount boot root
