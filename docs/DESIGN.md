# RAMLog Manager 0.3.0 — design and safety

## Apply workflow

1. Require root and verify that `/run` is tmpfs/ramfs.
2. Install systemd-tmpfiles rules for application log directories.
3. Configure journald volatile storage.
4. Discover supported service configuration files and apply service-specific RAM destinations.
5. Validate Apache, Nginx and PHP-FPM configuration before service restarts.
6. Restart only services whose configuration changed.
7. On any error, restore changed files from in-memory originals/backups and restart affected services.
8. Report adapters that remain unsupported; never silently claim full compliance.

## Adapters

- journald: managed drop-in under `/etc/systemd/journald.conf.d`.
- Apache: `APACHE_LOG_DIR` in `/etc/apache2/envvars`; virtual-host definitions remain untouched.
- Nginx: active `*.conf` files under `/etc/nginx`; validated with `nginx -t`.
- PHP-FPM: global `php-fpm.conf` files under `/etc/php/*/fpm`.
- PostgreSQL: online Debian clusters receive a managed `conf.d/ramlog-manager.conf` enabling the collector and RAM log directory. PostgreSQL restart causes a brief database interruption.
- Mattermost: `LogSettings.FileLocation` is redirected to RAM and file logging enabled; console settings are retained.\n- LightDM/Xorg: LightDM log directory and Xorg `-logfile` are directed to RAM through a LightDM drop-in; restarting LightDM terminates graphical sessions.
- rsyslog: an existing RAM ruleset is detected and preserved. Arbitrary rules are not rewritten.

## Known gaps

LightDM/Xorg adapter support depends on LightDM version and must be confirmed by runtime verification. rsyslog is not automatically translated when no RAM ruleset is present. Verification relies on lsof's view of open files under `/var/log`; it does not detect every possible persistent write or every application-specific log destination. These gaps must be closed before declaring a host fully compliant.

## Backups and historical data

Changed files are backed up under `/var/backups/ramlog-manager/<timestamp>/`. Existing historical logs and archives are never removed, truncated, or rewritten. Export accepts only configured sources verified as tmpfs/ramfs.
