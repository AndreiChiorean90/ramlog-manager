# RAMLog Manager

**Target:** Debian and Ubuntu servers using systemd  
**Release:** 0.1.0 (audit and archive foundation)

RAMLog Manager is an audit-first foundation for a RAM-first logging policy:

1. Active logs should be written to RAM.
2. Logs that cannot safely be redirected to RAM must be explicitly disabled.
3. At orderly shutdown/reboot, RAM logs should be archived to persistent storage.
4. Existing historical logs must not be deleted or rewritten.

## Important status of this release

This is **not yet a universal enforcement engine**. Version 0.1 provides:
- read-only audit of common logging locations and services;
- status reporting;
- a manual archive command;
- a systemd shutdown archive unit;
- a configuration file defining RAM sources and archive destination.

It does **not** automatically change journald, rsyslog, PostgreSQL, web servers, PHP-FPM, Mattermost, or other applications. That is deliberate: their logging configurations differ, and blindly rewriting production configurations could cause data loss or service disruption.

Do not claim a server is compliant merely because `ramlog status` runs. Review `ramlog audit` and ensure every application log source is covered by a tested adapter.

## Requirements

- Debian or Ubuntu
- systemd
- Python 3 (standard library only)
- root for full audit/archive/install

## Install

Extract the archive, then:

```bash
sudo ./install.sh
```

The installer copies the utility, configuration and shutdown unit. It does not modify existing logging configuration or activate RAM-only logging.

## Commands

```bash
sudo ramlog status
sudo ramlog audit
sudo ramlog export
```

- `status`: reports configured paths, filesystem types, services and archive destination.
- `audit`: lists persistent files under `/var/log`, processes with open files there (when `lsof` is installed), and logging service state.
- `export`: archives configured RAM sources into a timestamped `.tar.gz` file and writes a SHA-256 checksum manifest.

## Configuration

Edit `/etc/ramlog/ramlog.conf`:

```ini
[archive]
directory = /var/log/ramlog-archive

[sources]
paths = /run/log/journal,/run/rsyslog,/run/bjm-app-logs
```

Only add paths that are genuinely RAM-backed and contain logs. The tool checks each source path before archiving.

## Shutdown archive unit

The installer places `ramlog-export.service` in `/etc/systemd/system` and enables it. The unit runs the export command during orderly shutdown/reboot, before unmounting filesystems.

A shutdown archive is not guaranteed after power loss, kernel panic, forced reset, or storage failure. RAM contents can be lost in those cases.

## Safety

- No blanket `/var/log` tmpfs.
- No deletion/truncation of historical logs.
- No automatic `apt autoremove`.
- No automatic modification of application or database settings.
- No service is stopped by `audit` or `status`.
- Archive files are written with restrictive permissions.
- Review the audit report before implementing enforcement.

## Roadmap

- 0.2: tested journald and rsyslog RAM adapters with configuration backup/rollback.
- 0.3: PostgreSQL, Apache, Nginx, PHP-FPM and Mattermost adapters.
- 0.4: compliance verification that detects active persistent log writers.
- 1.0: tested Debian/Ubuntu support matrix and unattended-safe upgrade/rollback.

