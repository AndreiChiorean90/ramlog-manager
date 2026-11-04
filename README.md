# RAMLog Manager

**Target:** Debian and Ubuntu with systemd  
**Version:** 0.2.0 — guarded journald adapter and compliance verification

RAMLog Manager implements a RAM-first logging policy. Existing historical logs and archives are preserved.

## Commands

```bash
sudo ramlog status
sudo ramlog audit
sudo ramlog apply
sudo ramlog verify
sudo ramlog export
```

- `status`: reports configured source filesystems and service state.
- `audit`: inventories open files under `/var/log` and historical files.
- `apply`: configures journald for volatile storage on a RAM-backed `/run`, backs up the previous managed drop-in, and restarts journald. It does not rewrite application configs.
- `verify`: checks that journald and configured sources are RAM-backed, checks archive writability, and fails if lsof detects open persistent log writers.
- `export`: archives only configured paths verified to reside on tmpfs/ramfs, then writes a SHA-256 manifest.

## Scope and safety

This release has a managed journald adapter. It does **not** yet automatically rewrite Apache, Nginx, PHP-FPM, PostgreSQL, Mattermost, LightDM, Xorg or arbitrary application logging configurations. Such writers are reported by verification and cause an incomplete/failure result; they are never silently declared compliant or automatically disabled.

The rsyslog destination is not rewritten by this release because rules vary across Debian/Ubuntu installations. Configure it through a future tested adapter; its configured RAM path must be included in `/etc/ramlog/ramlog.conf`.

`apply` requires root and refuses to proceed unless `/run` is a tmpfs/ramfs mount. It backs up the managed journald drop-in before changing it. It does not delete or truncate historical logs, change database settings, or stop application services.

## Configuration

`/etc/ramlog/ramlog.conf`:

```ini
[archive]
directory = /var/log/ramlog-archive

[sources]
paths = /run/log/journal,/run/rsyslog,/run/bjm-app-logs
```

Only list verified RAM-backed log paths. Export refuses non-RAM sources.

## Shutdown export

The systemd unit invokes `ramlog export` before unmounting filesystems during orderly shutdown/reboot. Sudden power loss, kernel panic and forced reset can lose RAM logs. A successful manual export does not prove the shutdown hook has been exercised.

## Verification

A PASS is only as complete as the process visibility provided by `lsof`. Install `lsof` for process-level checks. This version detects open file descriptors under `/var/log`; it is not a universal syscall-level audit and cannot prove the absence of every possible persistent log writer.

## Roadmap

- 0.3: tested rsyslog adapter and service-specific adapters for Apache/Nginx/PHP-FPM/PostgreSQL/Mattermost.
- 1.0: broader Debian/Ubuntu compatibility matrix, unattended-safe upgrade/rollback and comprehensive verification.
