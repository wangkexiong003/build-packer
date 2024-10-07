#!/usr/bin/bash -x
SCRIPT_NAME="cleanup.sh"

/usr/bin/pacman -Rcns --noconfirm gptfdisk

# Clean the pacman cache.
echo "++++ ${SCRIPT_NAME}: Cleaning pacman cache.."
yes | /usr/bin/pacman -Scc

# Remove files
rm -rf /etc/resolv.conf.bak
> /etc/resolv.conf
