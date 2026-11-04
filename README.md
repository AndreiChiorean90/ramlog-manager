# RAMLog Manager

**Target:** Debian and Ubuntu with systemd  
**Version:** 0.3.0 — automatic service adapters (initial compatibility release)

RAMLog Manager configures supported logging services to use volatile storage under `/run`, preserves prior configuration backups, and exports configured RAM log sources during orderly shutdown.

## Install and use

```bash
sudo ./install.sh
sudo ramlog status
sudo ramlog apply
sudo ramlog verify
```

Run `apply` during a maintenance window. It may restart journald, rsyslog, Apache, Nginx, PHP-FPM, PostgreSQL clusters and Mattermost where their configuration changes. PostgreSQL restarts interrupt database connections.

## Adapters in 0.3.0

- **systemd-journald:** volatile journal with bounded runtime use.
- **Apache:** redirects the global `APACHE_LOG_DIR` through `/etc/apache2/envvars`; virtual-host files are not edited.
- **Nginx:** redirects configured access/error log directives in active configuration files and validates with `nginx -t`.
- **PHP-FPM:** redirects configured FPM global error logs.
- **PostgreSQL:** enables the logging collector and places its log directory under `/run` for online clusters.
- **Mattermost:** enables file logging in the RAM directory while retaining console logging and existing log levels.
- **rsyslog:** detects and preserves an existing RAM ruleset; it does not overwrite custom rules.

Runtime directories are created with systemd-tmpfiles. Configuration files changed by the manager are backed up under `/var/backups/ramlog-manager`. If a configuration validation or service restart fails, changed files are restored and affected services are restarted.

## Important limitations

This is an initial adapter release, not a universal guarantee. LightDM/Xorg and arbitrary third-party applications are not reconfigured automatically yet. rsyslog rules are not rewritten if a RAM ruleset is absent or incomplete. Unsupported writers remain visible to `verify` and prevent a PASS.

`verify` uses `lsof` to detect open persistent files under `/var/log`; install `lsof`. This is a practical process-level check, not a proof against every possible application writing elsewhere on persistent storage. Do not interpret a PASS as coverage of sources outside its detection scope.

## Data preservation

Historical files under `/var/log`, including historical journals, are not deleted or truncated. `export` archives only configured source directories whose filesystem is tmpfs/ramfs and writes a SHA-256 manifest. Unexpected power loss or kernel panic can lose logs still resident in RAM.

## Configuration

`/etc/ramlog/ramlog.conf`:

```ini
[archive]
directory = /var/log/ramlog-archive

[sources]
paths = /run/log/journal,/run/rsyslog,/run/bjm-app-logs
```

The existing configuration is preserved by the installer.
