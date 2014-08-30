# Installing base Arch Linux image on Raspberry Pi

## Installing image

* Run `install-image.sh`

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
