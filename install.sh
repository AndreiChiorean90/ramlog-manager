#!/bin/bash
set -euo pipefail
if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo ./install.sh" >&2
  exit 1
fi
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
command -v python3 >/dev/null || { echo "python3 is required" >&2; exit 1; }
for source in "$ROOT/bin/ramlog" "$ROOT/bin/ramlog-web"; do
  python3 -c 'import pathlib,sys; compile(pathlib.Path(sys.argv[1]).read_text(), sys.argv[1], "exec")' "$source" || { echo "Syntax validation failed: $source" >&2; exit 1; }
done
install -d -m 0755 /usr/local/sbin /etc/ramlog
install -m 0755 "$ROOT/bin/ramlog" /usr/local/sbin/ramlog
install -m 0755 "$ROOT/bin/ramlog-web" /usr/local/sbin/ramlog-web
if [[ ! -e /etc/ramlog/ramlog.conf ]]; then
  install -m 0640 "$ROOT/config/ramlog.conf" /etc/ramlog/ramlog.conf
else
  echo "Keeping existing /etc/ramlog/ramlog.conf"
fi
install -m 0644 "$ROOT/systemd/ramlog-export.service" /etc/systemd/system/ramlog-export.service
install -m 0644 "$ROOT/systemd/ramlog-web.service" /etc/systemd/system/ramlog-web.service
systemctl daemon-reload
systemctl enable ramlog-export.service
systemctl enable ramlog-web.service
systemctl restart ramlog-web.service
echo
echo "RAMLog Manager 0.3.7 web controller installed."
echo "Open http://SERVER-IP:7780/"
echo "The web Apply button runs only explicitly selected source adapters."
echo "Mixed and Unknown states are never selected automatically."
