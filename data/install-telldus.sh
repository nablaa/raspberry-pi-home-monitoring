#!/bin/bash

set -e
set -u

DIR="$(readlink -f "$(dirname "$0")")"
TEMP_DIR="install-temp"
SRC="https://aur.archlinux.org/packages/te/telldus-core/telldus-core.tar.gz"

cd "$DIR"
rm -rf "$TEMP_DIR"
mkdir "$TEMP_DIR"
wget "$SRC"
tar xvzf telldus-core.tar.gz
cd telldus-core
makepkg --syncdeps --noconfirm --install --asroot
