#!/usr/bin/bash -x

if [ -f /etc/pacman.d/mirrorlist.ori ]; then
  /bin/mv /etc/pacman.d/mirrorlist.ori /etc/pacman.d/mirrorlist
fi

