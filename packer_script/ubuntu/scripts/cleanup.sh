#!/bin/sh -eux

echo "remove linux-headers"
dpkg --list \
  | awk '{ print $2 }' \
  | grep 'linux-headers' \
  | xargs apt-get -y purge;

echo "remove linux-source package"
dpkg --list \
    | awk '{ print $2 }' \
    | grep linux-source \
    | xargs apt-get -y purge;

echo "remove all development packages"
dpkg --list \
    | awk '{ print $2 }' \
    | grep -- '-dev\(:[a-z0-9]\+\)\?$' \
    | xargs apt-get -y purge;

echo "remove docs packages"
dpkg --list \
    | awk '{ print $2 }' \
    | grep -- '-doc$' \
    | xargs apt-get -y purge;

echo "remove X11 libraries"
apt-get -y purge libx11-data xauth libxmuu1 libxcb1 libx11-6 libxext6 libxau6;

echo "remove obsolete networking packages"
apt-get -y purge ppp pppconfig pppoeconf;

echo "remove packages we don't need"
apt-get -y purge popularity-contest command-not-found* friendly-recovery bash-completion laptop-detect motd-news-config usbutils grub-legacy-ec2

# 22.04+ don't have this
echo "remove the fonts-ubuntu-font-family-console"
apt-get -y purge fonts-ubuntu-font-family-console || true;

# 21.04+ don't have this
echo "remove the installation-report"
apt-get -y purge popularity-contest installation-report || true;

echo "remove the console font"
apt-get -y purge fonts-ubuntu-console || true;

# Remove specific Linux kernels, such as linux-image-3.11.0-15-generic but
# keeps the current kernel and does not touch the virtual packages,
# e.g. 'linux-image-generic', etc.
PKGS_LINUX_IMAGE=( $(dpkg --list | awk '{ print $2 }' | grep -E '(linux-image-.*-generic)|(linux-cloud-tools.*)|(linux-tools.*)|(linux-modules.*)' | grep -v $(uname -r | sed 's/-generic//') | grep -v common || true) );
apt-get -y purge --autoremove "${PKGS_LINUX_IMAGE[@]:+${PKGS_LINUX_IMAGE[@]}}";
apt-get -y purge --autoremove linux-cloud-tools*

# Exclude the files we don't need w/o uninstalling linux-firmware
#echo "Setup dpkg excludes for linux-firmware"
#cat <<_EOF_ | cat >> /etc/dpkg/dpkg.cfg.d/excludes
##BENTO-BEGIN
#path-exclude=/lib/firmware/*
#path-exclude=/usr/share/doc/linux-firmware/*
##BENTO-END
#_EOF_

#echo "delete the massive firmware files"
#rm -rf /lib/firmware/*
#rm -rf /usr/share/doc/linux-firmware/*

# Remove firmware
apt-get -y purge --autoremove linux-firmware

# Delete some packages
PKGS_OTHER=( \
  usbutils \
  libusb-1.0-0 \
  binutils \
  console-setup \
  console-setup-linux \
  cpp* \
  wireless-regdb \
  eject \
  file \
  keyboard-configuration \
  krb5-locales \
  libmagic1 \
  make \
  manpages \
  netcat-openbsd \
  os-prober \
  tasksel \
  tasksel-data \
  vim-common \
  whiptail \
  xkb-data \
  pciutils \
  ubuntu-advantage-tools \
  tcpd \
  byobu git* \
  binutils make manpages libmpc3 \
  plymouth *gnome* \
  snapd \
);
apt-get -y purge --autoremove "${PKGS_OTHER[@]}";

PKGS_OTHER_ADDITION=( \
  crda \
  iw \
);
apt-get -y purge --autoremove "${PKGS_OTHER_ADDITION[@]}";

echo "autoremoving packages and cleaning apt data"
apt-get -y autoremove;
apt-get -y clean;
rm -rf /var/lib/apt/*;
mkdir -p /var/lib/apt/lists;
rm -rf /var/log/vboxadd*

echo "remove /usr/share/doc/"
rm -rf /usr/share/doc/*

echo "remove /var/cache"
find /var/cache -type f -exec rm -rf {} \;

echo "truncate any logs that have built up during the install"
find /var/log -type f -exec truncate --size=0 {} \;

echo "blank netplan machine-id (DUID) so machines get unique ID generated on boot"
truncate -s 0 /etc/machine-id

echo "remove the contents of /tmp and /var/tmp"
rm -rf /tmp/* /var/tmp/*

echo "force a new random seed to be generated"
rm -f /var/lib/systemd/random-seed

echo "clear the history so our install isn't there"
rm -f /root/.wget-hsts

# remove floppy
sed -i '/.*\/media\/floppy.*/d' /etc/fstab

export HISTSIZE=0

