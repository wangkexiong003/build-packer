#!/usr/bin/bash -x
SCRIPT_NAME="workaround.sh"

# http://comments.gmane.org/gmane.linux.arch.general/48739
echo "++++ ${SCRIPT_NAME}: Adding workaround for shutdown race condition.."
cat <<-EOF > /etc/systemd/system/poweroff.timer
[Unit]
Description=Delayed poweroff

[Timer]
OnActiveSec=1
Unit=poweroff.target
EOF
/usr/bin/chmod 0644 /etc/systemd/system/poweroff.timer

