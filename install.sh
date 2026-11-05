#!/bin/bash
set -euo pipefail
if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo ./install.sh" >&2
  exit 1
fi
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
command -v python3 >/dev/null || { echo "python3 is required" >&2; exit 1; }
python3 -c 'import pathlib,sys; compile(pathlib.Path(sys.argv[1]).read_text(), sys.argv[1], "exec")' "$ROOT/bin/ramlog" || { echo "RAMLog Manager syntax validation failed; nothing installed." >&2; exit 1; }
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
echo "RAMLog Manager 0.3.1 installed (Python syntax check passed)."
echo "Existing configuration preserved. No application services were changed."
echo "Run: ramlog status"
echo "Then, during a maintenance window, run: ramlog apply"
echo "Finally run: ramlog verify"
