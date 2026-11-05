# RAMLog Manager

**Target:** Debian and Ubuntu with systemd  
**Web policy UI:** 0.3.2 (standalone Python standard-library HTTP server)

## Standalone web interface

Run `sudo ./install.sh`, then open:

`http://SERVER-IP:7780/`

The installer enables `ramlog-web.service`. The interface uses Python's standard library; it does not require Apache, Nginx, PHP, Node.js, Flask, or other packages. It listens on TCP port 7780.

The page lists the initial known log-source candidates. Each row has a checkbox and a three-state policy: **Disabled**, **RAM**, or **HDD**. Changing a selector automatically checks its row. Apply saves only checked rows to `/etc/ramlog/policy.json`; unchecked rows are left unchanged.

**Important: this first web-interface release is a policy editor, not yet a live logging controller.** Apply persists the desired policy but does not rewrite service configuration, stop logging, move active file descriptors, or restart services. No source is silently reported as changed. The live per-source adapter/activation engine is not implemented in this release.

The web server currently binds to `0.0.0.0:7780` and has no authentication or TLS. Restrict access to a trusted management network using the host firewall; do not expose this port to the Internet.

## Existing command-line tools

The existing CLI remains installed:

```bash
sudo ramlog status
sudo ramlog audit
sudo ramlog verify
sudo ramlog export
```

The legacy `ramlog apply` command is a bulk adapter operation from 0.3.1. It is separate from the web policy editor and should not be run as a substitute for per-source Apply.

## Data preservation

Historical files under `/var/log`, including historical journals, are not deleted or truncated. RAM-resident logs are exported by the existing shutdown exporter to the configured archive directory. Unexpected power loss or kernel panic can lose logs still resident in RAM.

Existing `/etc/ramlog/ramlog.conf` is preserved by the installer. The policy UI creates `/etc/ramlog/policy.json` only when Apply is used.
