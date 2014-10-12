# Installing base Arch Linux image on Raspberry Pi

## Installing image

* Run `install-image.sh`

## Starting Raspberry Pi

* Plug in SD card to Raspberry Pi and connect ethernet cable
* Start Raspberry Pi
* SSH to Pi and install necessary packages
```
pacman -Syu
pacman -S python2 iw wpa_supplicant wpa_actiond
```
* Unplug ethernet cable and reboot

# Running Ansible

* Ping
```
ansible -i hosts all -m ping --ask-pass -u root
```

* Initial setup
```
ansible-playbook -i hosts initial-setup.yml --ask-pass
ansible-playbook -i hosts dotfiles.yml
ansible-playbook -i hosts telldus.yml
ansible-playbook -i hosts monitoring.yml
```
