#!/bin/sh -eux

# determine the major EL version we're runninng
major_version=$(sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release | awk -F. '{print $1}')

# make sure we use dnf on EL 8+
if [ "${major_version}" -ge 8 ]; then
  pkg_cmd="dnf"
else
  pkg_cmd="yum"
fi
${pkg_cmd} -y update

# Updating the oracle release on at least OL 6 updates the repos and unlocks a whole
# new set of updates that need to be applied. If this script is there it should be run
if [ -f "/usr/bin/ol_yum_configure.sh" ]; then
  /usr/bin/ol_yum_configure.sh
  yum -y update
fi

# Additional Software
${pkg_cmd} -y install tar nfs-utils cifs-utils rsync

case "${PACKER_BUILDER_TYPE}" in
virtualbox-iso|virtualbox-ovf)
  ${pkg_cmd} -y install \
    gcc make cpp perl bzip2 \
    kernel-devel kernel-headers elfutils-libelf-devel
  ;;
esac

reboot

