# Installing base Arch Linux image on Raspberry Pi

## Installing image

Run `install-image.sh` to create initial Arch Linux image on an SD card.

    sudo ./install-image.sh /dev/sdX myhostname

Where `/dev/sdX` is the SD card device. The hostname of the created Linux
will be set to `myhostname`.

## Starting Raspberry Pi

* Plug in SD card to Raspberry Pi and connect ethernet cable
* Start Raspberry Pi

Using WLAN and running ansible requires installation of few packages:

    pacman -Syu --noconfirm
    pacman -S --noconfirm python2 iw wpa_supplicant wpa_actiond

After this the ethernet cable can be unplugged and the Raspberry Pi
can be rebooted. Now the Pi should connect to WLAN network using a
WLAN adapter.

# Running Ansible

You can check that Ansible can ping the newly created image:

    ansible -i hosts all -m ping --ask-pass -u root

To install the system using Ansible, run the following commands:

    ansible-playbook -i hosts initial-setup.yml --ask-pass
    ansible-playbook -i hosts dotfiles.yml
    ansible-playbook -i hosts telldus.yml
    ansible-playbook -i hosts monitoring.yml
