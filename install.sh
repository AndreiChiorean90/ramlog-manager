#!/bin/bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo ./install.sh" >&2
  exit 1
fi

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
install -d -m 0755 /usr/local/sbin /etc/ramlog
install -m 0755 "$ROOT/bin/ramlog" /usr/local/sbin/ramlog
if [[ ! -e /etc/ramlog/ramlog.conf ]]; then
  install -m 0640 "$ROOT/config/ramlog.conf" /etc/ramlog/ramlog.conf
else
  echo "Keeping existing /etc/ramlog/ramlog.conf"
fi
install -m 0644 "$ROOT/systemd/ramlog-export.service" /etc/systemd/system/ramlog-export.service
systemctl daemon-reload
systemctl enable ramlog-export.service

echo
echo "RAMLog Manager 0.2.0 installed."
echo "Existing configuration was preserved."
echo "No application logging configuration was changed by installation."
echo "Run: ramlog status"
echo "Run: ramlog audit"
echo "Run: ramlog verify"
echo "Run: ramlog apply (journald adapter only)"
