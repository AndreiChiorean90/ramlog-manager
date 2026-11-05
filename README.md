# RAMLog Manager

**Target:** Debian and Ubuntu with systemd  
**Web controller:** 0.3.3 (Python standard library)

## Install

Run as root:

```bash
chmod 755 install.sh
./install.sh
```

Open `http://SERVER-IP:7780/`. The installer updates the CLI and web controller and enables `ramlog-web.service`.

## Current web Apply behavior — read before use

The web interface persists the selected policy in `/etc/ramlog/policy.json`.

This build connects the Apply button to the existing guarded `ramlog apply` adapter **only when all nine listed sources are checked and set to RAM**. In that exact case, the CLI attempts to configure RAM logging for journald, rsyslog, Apache, Nginx, PHP-FPM, PostgreSQL, Mattermost, and LightDM/Xorg. It validates Apache/Nginx/PHP-FPM configurations where available, backs up changed files under `/var/backups/ramlog-manager`, and attempts rollback if the adapter reports a failure. Service restarts may occur, including PostgreSQL and Mattermost. LightDM/Xorg activation is staged for the next planned reboot to avoid terminating active desktop sessions.

**Mixed policies are not implemented yet.** If any row is unchecked or set to HDD/Disabled, the UI saves the policy but deliberately does not run the bulk adapter. It must not be interpreted as per-source HDD/Disabled enforcement.

The bulk adapter is an initial host adapter, not proof of complete compliance on every Debian/Ubuntu system. After applying, inspect the execution output, run `ramlog verify`, and independently confirm that no active processes are writing logs to persistent storage. A PASS is meaningful only for the sources and processes actually detected by the host. Do not assume every application is covered merely because it appears in the interface.

## CLI

```bash
ramlog status
ramlog audit
ramlog apply
ramlog verify
ramlog export
```

`ramlog apply` is the same guarded bulk adapter used by the web UI's all-RAM policy. Do not run it if you do not intend the service configuration changes and restarts described above.

## Shutdown archive and data preservation

The shutdown exporter archives the RAM paths listed in `/etc/ramlog/ramlog.conf` to `/var/log/ramlog-archive` and writes a SHA-256 manifest. Historical files under `/var/log` are not deleted or truncated. Unexpected power loss or kernel panic can lose logs still resident in RAM.

The installer preserves an existing `/etc/ramlog/ramlog.conf`.

## Network security

The web server binds to `0.0.0.0:7780` and currently has no authentication or TLS. Restrict TCP 7780 to a trusted management network using the host firewall. Never expose it to the Internet.
