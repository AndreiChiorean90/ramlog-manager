# Design and safety notes

## Policy model

Every logging source must resolve to exactly one of:
- `RAM`: active logging redirected to a verified tmpfs path and included in shutdown archive.
- `DISABLED`: logging explicitly disabled because safe RAM redirection is unavailable.

Persistent active logging is never an accepted steady state.

## Adapter contract (planned)

An adapter must:
1. identify the service and its active configuration;
2. determine whether its log destination is persistent;
3. back up every file it changes;
4. configure a dedicated RAM destination (not a blanket `/var/log` mount);
5. validate configuration before reload/restart;
6. verify actual open file destinations after reload;
7. register RAM paths for shutdown export;
8. provide rollback;
9. refuse to claim success if verification is inconclusive.

## Why v0.1 does not apply adapters

Logging configuration is distribution-, package- and application-dependent. For example, PostgreSQL may write to stderr captured by journald even when `logging_collector=off`; Mattermost can log to console and files; rsyslog may create multiple files through distro-specific rules. A generic rewrite could silently lose diagnostics or disrupt production.

## Archive ordering

The shutdown unit is ordered before filesystem unmount. The archive command copies configured RAM paths into a persistent archive directory. This cannot protect against sudden power loss or a hard reset.

## Verification still required

A production-ready compliance verifier must inspect:
- journald storage mode and active journal paths;
- rsyslog rules and open file descriptors;
- application-specific file destinations;
- systemd unit stdout/stderr destinations;
- kernel/audit logging;
- tmpfs capacity and free space;
- archive success and checksums.
