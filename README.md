# Home monitoring system with Raspberry Pi computers

## Installing Arch Linux on Raspberry Pi

Run `install-image.sh` to create initial Arch Linux image on an SD card.

    sudo ./install-rpi-arch-linux.sh /dev/sdX myhostname wlan-ap wlan-password

Where `/dev/sdX` is the SD card device. The hostname of the created Linux
will be set to `myhostname`. The script will setup WLAN configuration so that
when the machine is restarted after installing WLAN packages in the next
section, the WLAN connection should work automatically.

## Starting Raspberry Pi

* Plug in SD card to Raspberry Pi and connect ethernet cable
* Start Raspberry Pi

In order to use WLAN and run Ansible, certain packages are required:

    pacman -Syu --noconfirm
    pacman -S --noconfirm python2 iw wpa_supplicant wpa_actiond

After this the ethernet cable can be unplugged and the Raspberry Pi
can be rebooted. Now the Pi should connect to WLAN network using a
WLAN adapter.

## Configuring monitoring server

Create password hash:

    python -c 'from passlib.hash import sha256_crypt; print(sha256_crypt.encrypt("MYPASSWORD"))' > roles/monitoring-server/files/home-monitoring-server-configs/password

Create (self-signed) certificate for HTTPS:

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout roles/monitoring-server/files/home-monitoring-server-configs/server.key -out roles/monitoring-server/files/home-monitoring-server-configs/server.crt

See [home-monitoring-server](https://github.com/nablaa/home-monitoring-server)
project for more details.

Edit dy.fi dynamic DNS configuration in `roles/dyndns/files/dy-update.service`.

## Running Ansible

You can check that Ansible can ping the newly created image:

    ansible -i hosts all -m ping --ask-pass -u root

To install the system using Ansible, run the following commands:

    ansible-playbook -i hosts home-monitoring-system.yml --ask-pass

Reboot all machines after installation has finished:

    ansible all -i hosts -u root -m shell -a "/sbin/reboot"
