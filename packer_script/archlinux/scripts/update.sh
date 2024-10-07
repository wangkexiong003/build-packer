#!/usr/bin/bash -x
SCRIPT_NAME="update.sh"

# VirtualBox Guest Additions
# https://wiki.archlinux.org/index.php/VirtualBox/Install_Arch_Linux_as_a_guest
echo "++++ ${SCRIPT_NAME}: Installing VirtualBox Guest Additions"
/usr/bin/pacman -S --noconfirm virtualbox-guest-utils-nox

echo "++++ ${SCRIPT_NAME}: Enabling VirtualBox Guest service.."
/usr/bin/systemctl enable vboxservice.service

# Add groups for VirtualBox folder sharing
echo "++++ ${SCRIPT_NAME}: Enabling VirtualBox Shared Folders.."
/usr/bin/usermod --append --groups vagrant,vboxsf vagrant

