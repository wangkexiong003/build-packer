#!/usr/bin/env bash

# stop on errors
set -eu

if [[ ${PACKER_BUILDER_TYPE} == "qemu" ]]; then
  DISK='/dev/vda'
else
  DISK='/dev/sda'
fi

HOSTNAME='archlinux'
KEYMAP='us'
LANGUAGE='en_US.UTF-8'
PASSWORD=$(/usr/bin/openssl passwd -6 vagrant)
TIMEZONE='UTC'

CONFIG_SCRIPT='/usr/local/bin/arch-config.sh'
EFI_PARTITION="${DISK}1"
ROOT_PARTITION="${DISK}2"
TARGET_DIR='/mnt'
TARGET_EFI="${TARGET_DIR}/boot/efi"
SWAPFILE="/swap/swapfile"
COUNTRY=${COUNTRY:-US}
SCRIPT_NAME="bootstrap.sh"

###########################################################
###########################################################

echo "++++ ${SCRIPT_NAME}: Clearing partition table on ${DISK}.."
/usr/bin/sgdisk --zap-all ${DISK}

echo "++++ ${SCRIPT_NAME}: Destroying magic strings and signatures on ${DISK}.."
/usr/bin/dd if=/dev/zero of=${DISK} bs=512 count=2048
/usr/bin/wipefs --all ${DISK}

echo "++++ ${SCRIPT_NAME}: Creating partition on ${DISK}.."
/usr/bin/sgdisk --new=1:0:+64M --typecode=1:EF00 ${DISK}
/usr/bin/sgdisk --new=2:0:0    --typecode=2:8300 ${DISK}

echo "++++ ${SCRIPT_NAME}: Creating filesystem (ext4).."
/usr/bin/mkfs.fat  -F32 ${EFI_PARTITION}
/usr/bin/mkfs.ext4 -F -m 0 -q -L root ${ROOT_PARTITION}

echo "++++ ${SCRIPT_NAME}: Mounting ${ROOT_PARTITION} to ${TARGET_DIR}.."
/usr/bin/mount -o noatime,errors=remount-ro ${ROOT_PARTITION} ${TARGET_DIR}
mkdir -p ${TARGET_EFI}
/usr/bin/mount -o noatime,errors=remount-ro ${EFI_PARTITION}  ${TARGET_EFI}

echo "++++ ${SCRIPT_NAME}: Setting pacman mirrors.."
mkdir -p ${TARGET_DIR}/etc/pacman.d
mv /etc/pacman.d/mirrorlist ${TARGET_DIR}/etc/pacman.d/mirrorlist.ori
if [ -f /etc/pacman.d/_mirrors ]; then
  source /etc/pacman.d/_mirrors
  echo "Server = ${ARCH_REPO}"'/$repo/os/$arch' > /etc/pacman.d/mirrorlist
else
  MIRRORLIST="https://archlinux.org/mirrorlist/?country=${COUNTRY}&protocol=http&protocol=https&ip_version=4&use_mirror_status=on"
  /usr/bin/curl -fsSL "${MIRRORLIST}" | /usr/bin/sed 's/^#Server/Server/' > /etc/pacman.d/mirrorlist
fi

echo "++++ ${SCRIPT_NAME}: Bootstrapping the base installation.."
pacman-key --init
pacman-key --populate archlinux
/usr/bin/pacstrap ${TARGET_DIR} linux base sudo

echo "++++ ${SCRIPT_NAME}: Generating the swap file.."
/usr/bin/mkdir -p "$(/usr/bin/dirname ${TARGET_DIR}/${SWAPFILE})"
/usr/bin/dd if=/dev/zero of="${TARGET_DIR}/${SWAPFILE}" bs=1M count=2048 status=progress
/usr/bin/chmod 0600 "${TARGET_DIR}/${SWAPFILE}"
/usr/bin/mkswap "${TARGET_DIR}/${SWAPFILE}"

echo "++++ ${SCRIPT_NAME}: Generating the filesystem table.."
/usr/bin/genfstab -p ${TARGET_DIR} >> "${TARGET_DIR}/etc/fstab"
echo "${SWAPFILE} none swap defaults 0 0" >> ${TARGET_DIR}/etc/fstab

echo "++++ ${SCRIPT_NAME}: Installing UEFI"
/usr/bin/arch-chroot ${TARGET_DIR} pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools
/usr/bin/arch-chroot ${TARGET_DIR} grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
/usr/bin/arch-chroot ${TARGET_DIR} grub-mkconfig -o /boot/grub/grub.cfg

echo "++++ ${SCRIPT_NAME}: Installing sshd.."
/usr/bin/arch-chroot ${TARGET_DIR} pacman -S --noconfirm dhcpcd netctl rng-tools openssh

echo "++++ ${SCRIPT_NAME}: Generating the system configuration script.."
/usr/bin/install --mode=0755 /dev/null "${TARGET_DIR}${CONFIG_SCRIPT}"

CONFIG_SCRIPT_SHORT=$(/usr/bin/basename "$CONFIG_SCRIPT")
cat <<-EOF > "${TARGET_DIR}${CONFIG_SCRIPT}"
  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Configuring hostname, timezone, and keymap.."
  echo '${HOSTNAME}' > /etc/hostname
  /usr/bin/ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
  echo 'KEYMAP=${KEYMAP}' > /etc/vconsole.conf

  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Configuring locale.."
  /usr/bin/sed -i 's/#${LANGUAGE}/${LANGUAGE}/' /etc/locale.gen
  /usr/bin/locale-gen
  if [ -f /etc/locale.conf ]; then
    /usr/bin/sed -i 's/^LANG=.*/LANG=en_US.UTF-8/' /etc/locale.conf
  else
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
  fi

  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Creating initramfs.."
  /usr/bin/mkinitcpio -p linux

  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Setting root pasword.."
  /usr/bin/usermod --password ${PASSWORD} root
  echo -e 'vagrant\nvagrant' | /usr/bin/passwd root

  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Configuring network.."
  # Disable systemd Predictable Network Interface Names and revert to traditional interface names
  # https://wiki.archlinux.org/index.php/Network_configuration#Revert_to_traditional_interface_names
  /usr/bin/ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules
  /usr/bin/systemctl enable dhcpcd@eth0.service

  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Configuring sshd.."
  /usr/bin/sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
  /usr/bin/systemctl enable sshd.service

  # Workaround for https://bugs.archlinux.org/task/58355 which prevents sshd to accept connections after reboot
  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Adding workaround for sshd connection issue after reboot.."
  /usr/bin/systemctl enable rngd

  # Vagrant-specific configuration
  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Creating vagrant user.."
  /usr/bin/useradd --password ${PASSWORD} --comment 'Vagrant User' --create-home --user-group vagrant
  echo -e 'vagrant\nvagrant' | /usr/bin/passwd vagrant

  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Configuring sudo.."
  echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/10_vagrant
  echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/10_vagrant
  /usr/bin/chmod 0440 /etc/sudoers.d/10_vagrant

  echo ">>>> ${CONFIG_SCRIPT_SHORT}: Enable resolver service.."
  /usr/bin/systemctl enable systemd-resolved.service
EOF

echo "++++ ${SCRIPT_NAME}: Entering chroot and configuring system.."
/usr/bin/arch-chroot ${TARGET_DIR} ${CONFIG_SCRIPT}
rm "${TARGET_DIR}${CONFIG_SCRIPT}"

echo "++++ ${SCRIPT_NAME}: Completing installation.."
/usr/bin/umount ${TARGET_EFI}
/usr/bin/sleep 3
/usr/bin/umount ${TARGET_DIR}

# Turning network interfaces down to make sure SSH session was dropped on host.
# More info at: https://www.packer.io/docs/provisioners/shell.html#handling-reboots
#echo "++++ ${SCRIPT_NAME}: Turning down network interfaces and rebooting"
#for i in $(/usr/bin/ip -o link show | /usr/bin/awk -F': ' '{print $2}'); do /usr/bin/ip link set ${i} down; done
/usr/bin/systemctl reboot
