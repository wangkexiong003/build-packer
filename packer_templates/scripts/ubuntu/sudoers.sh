#!/bin/sh -eux

ubuntu_version="$(lsb_release -r | awk '{print $2}')";
major_version="$(echo ${ubuntu_version} | awk -F. '{print $1}')";

# No exempt_group for sudo after ubuntu26.04
if [ "${major_version}" -le "24" ]; then
  sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=sudo' /etc/sudoers;
fi

# Set up password-less sudo for the vagrant user
echo 'vagrant ALL=(ALL) NOPASSWD:ALL' >/etc/sudoers.d/99_vagrant;
chmod 440 /etc/sudoers.d/99_vagrant;

