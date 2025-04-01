#!/bin/bash

ubuntu_version="$(lsb_release -r | awk '{print $2}')";
major_version="$(echo ${ubuntu_version} | awk -F. '{print $1}')";

# Start from Ubuntu20, new live image is introduced instead of legacy image.
#   And in subiquity mode, hostname is a must field in userdata...
if [ "${major_version}" -ge 20 ]; then
  new_hostname="ubuntu${major_version}"
  echo "${new_hostname}" > /etc/hostname

  sed -ri "s/^(([0-9]{1,3}\.){3}[0-9]{1,3}.*)vagrant/\1${new_hostname}/g" /etc/hosts
fi
