#!/bin/sh -eux

bento='
The system is built inspired by the Bento project from Chef Software
Happy with vagrant working.
'

if [ -d /etc/update-motd.d ]; then
  MOTD_CONFIG='/etc/update-motd.d/99-bento'

  cat >> "${MOTD_CONFIG}" <<BENTO
#!/bin/sh

cat <<'EOF'
$bento
EOF
BENTO

  chmod 0755 "${MOTD_CONFIG}"
else
  echo "${bento}" >> /etc/motd
fi

