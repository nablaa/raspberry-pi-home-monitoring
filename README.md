# Installing base Arch Linux image on Raspberry Pi

## Installing image

* These instructions are from
[Arch Linux ARM Raspberry Pi installation](http://archlinuxarm.org/platforms/armv6/raspberry-pi)
* Insert SD card (`/dev/sdX`) to host machine and execute following instructions as root
* Install partitions
```
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
" | fdisk /dev/sdX
```

* Create and mount the FAT filesystem
```
mkfs.vfat /dev/sdX1
mkdir boot
mount /dev/sdX1 boot
```

* Create and mount the ext4 filesystem
```
mkfs.ext4 /dev/sdX2
mkdir root
mount /dev/sdX2 root
```

* Download and extract the root filesystem
```
wget http://archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz
tar -xf ArchLinuxARM-rpi-latest.tar.gz -C root
sync
```

* Move boot files to the first partition
```
mv root/boot/* boot
```

* Unmount partitions
```
sync
umount boot root
```

## Starting Raspberry Pi

* Plug in SD card to Raspberry pi
* Start Raspberry Pi
* SSH to Pi and install Python 2
```
pacman -Syu
pacman -S python2
```

# Running Ansible

* Ping
```
ansible -i hosts all -m ping --ask-pass -u root
```

* Initial setup
```
ansible-playbook -i hosts initial-setup.yml --ask-pass
ansible-playbook -i hosts dotfiles.yml
```
