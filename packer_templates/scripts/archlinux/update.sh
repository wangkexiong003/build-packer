#!/usr/bin/bash -x
SCRIPT_NAME="update.sh"

echo "++++ ${SCRIPT_NAME}: Installing Additional Packages..."
pacman -Syu --noconfirm cifs-utils rsync moreutils
