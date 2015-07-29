#!/bin/bash

set -e
set -u

TEMP_DIR="$(mktemp -d)"
SRC="https://aur.archlinux.org/packages/te/telldus-core/telldus-core.tar.gz"

cleanup() {
    rm -rf "$TEMP_DIR"
}

echo "Installing dependencies"
pacman -S --noconfirm --asdeps libftdi-compat confuse gcc make cmake

echo "Temp directory: $TEMP_DIR"
trap cleanup EXIT

cd "$TEMP_DIR"
wget "$SRC"
tar xvzf telldus-core.tar.gz
cd telldus-core
chown -R pi:pi "$TEMP_DIR"

echo "Making Telldus package"
sudo -u pi makepkg --noconfirm

echo "Installing Telldus package"
pacman -U --noconfirm "$TEMP_DIR/telldus-core/telldus-core-2.1.2-1-armv6h.pkg.tar.xz"
