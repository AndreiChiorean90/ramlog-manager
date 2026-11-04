# RAMLog Manager 0.2.0 — design and safety

## Implemented adapter

### systemd-journald
- Requires /run to be mounted as tmpfs or ramfs.
- Backs up the managed drop-in under /var/backups/ramlog-manager/<timestamp>/.
- Writes Storage=volatile and bounded runtime usage.
- Restarts systemd-journald and rolls back the drop-in if restart fails.

## Verification contract

The verifier checks runtime journal filesystem, configured source filesystems, archive destination writability, and open persistent files visible to lsof. Missing lsof is a verification failure, not a pass.

## Not yet automated

rsyslog, Apache, Nginx, PHP-FPM, PostgreSQL, Mattermost, LightDM and Xorg require package- and installation-specific adapters. The tool must report these as remaining persistent writers rather than rewrite arbitrary configs or disable logging.

## Data preservation

Historical files under /var/log are not removed, truncated, rotated, or rewritten. Export accepts only source paths whose filesystem is tmpfs or ramfs.
