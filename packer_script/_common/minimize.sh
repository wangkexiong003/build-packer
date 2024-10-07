#!/bin/sh -eux

case "${PACKER_BUILDER_TYPE}" in
  qemu) exit 0 ;;
esac

set +e
swapuuid=$(blkid -o value -l -s UUID -t TYPE=swap)
case "$?" in
  2|0) ;;
  *) exit 1 ;;
esac
set -e

if [ "x${swapuuid}" != "x" ]; then
  # Whiteout the swap partition to reduce box size
  # Swap is disabled till reboot
  swappart=$(readlink -f /dev/disk/by-uuid/$swapuuid)
  swapoff "${swappart}"
  dd if=/dev/zero of="${swappart}" bs=1M || echo "dd exit code $? is suppressed"
  mkswap -U "${swapuuid}" "${swappart}"
else
  swapfile=$(cat /etc/fstab | grep -v "^#" | awk '{if ($3=="swap") printf $1}')
  if [ "x${swapfile}" != "x" ] && [ -f ${swapfile} ]; then
    swapoff ${swapfile}
    sed -i "/^${swapfile//\//\\/}/d" /etc/fstab

    # The reason why not using fallocate
    # https://unix.stackexchange.com/questions/294600/i-cant-enable-swap-space-on-centos-7
    rm -rf ${swapfile}
  fi

  mkdir -p /swap
  dd if=/dev/zero of=/swap/swapfile count=2048 bs=1M
  chmod 0600 /swap/swapfile
  mkswap /swap/swapfile
  echo '/swap/swapfile none swap defaults 0 0' | sudo tee -a /etc/fstab
fi

# Whiteout root
zerofile=$(mktemp /zerofile.XXXXX)
dd if=/dev/zero of="$zerofile" bs=1M || echo "dd exit code $? is suppressed"
rm -f "$zerofile"
sync

