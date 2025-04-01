#!/bin/sh -eux

## SHOULD BE NEVER USED AGAIN.
##   alreay upgrade kernel and linux-cloud-tools in unattended script...

## command `apt-get -y dist-upgrade` may NOT upgrade linux-cloud-tools
## Sometimes packer will fail with SSH connection when kernel and linux-cloud-tools DO NOT match.

ubuntu_version="$(lsb_release -r | awk '{print $2}')";
major_version="$(echo ${ubuntu_version} | awk -F. '{print $1}')";

case "${PACKER_BUILDER_TYPE}" in
hyperv-iso)
  if [ "${major_version}" -eq "16" ]; then
    apt-get install -y linux-tools-virtual-lts-xenial linux-cloud-tools-virtual-lts-xenial;
  else
    apt-get -y install linux-image-virtual linux-tools-virtual linux-cloud-tools-virtual;
  fi
esac

