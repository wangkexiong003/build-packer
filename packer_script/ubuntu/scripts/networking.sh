#!/bin/sh -eux

ubuntu_version="$(lsb_release -r | awk '{print $2}')";
major_version="$(echo ${ubuntu_version} | awk -F. '{print $1}')";

DEVICE_NAME=$(ls /sys/class/net | grep -v lo | head -1)

if [ "${major_version}" -ge "18" ]; then
  echo "Check netplan config..."
  if ! grep -qoz "network:.*ethernets:.*${DEVICE_NAME}:.*dhcp4:.*yes" /etc/netplan/* 2>/dev/null; then
    mkdir -p /etc/netplan
    cat <<EOF > /etc/netplan/01-netcfg.yaml;
network:
  version: 2
  renderer: networkd
  ethernets:
    $DEVICE_NAME:
      dhcp4: true
EOF
  fi
else
  # Adding a 2 sec delay to the interface up, to make the dhclient happy
  echo "pre-up sleep 2" >> /etc/network/interfaces;
fi

#if [ "$major_version" -ge "16" ]; then
#  # Disable Predictable Network Interface names and use eth0
#  sed -i 's/en[[:alnum:]]*/eth0/g' /etc/network/interfaces;
#  sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0 \1"/g' /etc/default/grub;
#  update-grub;
#fi
