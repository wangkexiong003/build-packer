#!/bin/sh -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR="${HOME_DIR:-/home/vagrant}";

case "${PACKER_BUILDER_TYPE}" in
virtualbox-iso|virtualbox-ovf)
  VER=$(cat ${HOME_DIR}/.vbox_version)
  ISO="VBoxGuestAdditions_${VER}.iso";
  if [ -f ${HOME_DIR}/${ISO} ]; then
    mkdir -p /tmp/vbox;
    mount -o loop ${HOME_DIR}/${ISO} /tmp/vbox;
    sh /tmp/vbox/VBoxLinuxAdditions.run \
        || ( [ -f /var/log/vboxadd-setup.log ] && cat /var/log/vboxadd-setup.log )
    umount /tmp/vbox;
    rm -rf /tmp/vbox;
    rm -f ${HOME_DIR}/*.iso;
  fi
  ;;
esac

