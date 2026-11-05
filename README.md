# RAMLog Manager

**Target:** Debian and Ubuntu with systemd  
**Web controller:** 0.3.9 (Python standard library)

## Install

Run as root:

```bash
chmod 755 install.sh
./install.sh
```

Open `http://SERVER-IP:7780/`. The installer updates the CLI and web controller and enables `ramlog-web.service`.

## Live inventory and controlled actions\n\nThe web UI provides **Check current log status**, which inventories active file descriptors whose paths look like log locations or use common log-file suffixes, classifies their backing filesystem as RAM or HDD, and reports explicitly disabled Mattermost file logging only when configuration proves it. Unusual extensionless paths and remote/syslog destinations may require application-specific adapters. Missing files are not assumed to mean Disabled. This inventory is discovery evidence, not proof that every application log source has been found.\n\nA separate **Mattermost-only correction** action changes `LogSettings.FileLocation` to `/run/bjm-app-logs/mattermost`, backs up the configuration, and restarts only the Mattermost service. It refuses to run if Mattermost is not already active.\n\n## Change-aware, source-scoped Apply

The web UI compares each source's live state with its saved target policy. RAM is the default target for a new source. A row is checked automatically only when its live inventory contains positively identified HDD log writers and its target is RAM. RAM, Mixed, Unknown, and sources with no active writer are never auto-selected. Source matching uses exact process identities and known destination paths rather than loose substring matches. An unchanged RAM source remains unchecked.

Apply passes only explicitly checked sources to the source-scoped CLI operation. It does not invoke the former all-sources bulk adapter. Each selected adapter writes managed configuration only when it differs and restarts only the affected service(s) when they are already active. If LightDM/Xorg is selected, the manager also detects stale persistent GUI log descriptors and can restart LightDM to activate the staged RAM paths. PostgreSQL and LightDM selections require an explicit browser confirmation because their restarts can interrupt database connections or graphical sessions; the CLI independently enforces `--confirm-disruptive`. Inactive services are not started automatically. PostgreSQL is not selected or modified merely because other sources are selected; a Mixed PostgreSQL state remains unchecked unless an operator explicitly selects it.

The current adapters implement RAM targets only. Selecting HDD or Disabled saves the policy but does not apply those targets; those adapters are not implemented yet. The selected adapters may ensure their shared runtime directories; logrotate is not modified by selective Apply. Review the output and run `ramlog verify`; FAIL/INCOMPLETE is not compliance.

The state comparison is a live inventory, not an immutable historical snapshot. Active file-descriptor discovery can miss unusual extensionless paths and remote/syslog destinations. Mixed/Unknown are intentionally treated as requiring human review, not as permission to change a source. The legacy CLI command `ramlog apply` remains a bulk operation and must not be used for selective policy changes.


## Shutdown archive and data preservation

The shutdown exporter archives the RAM paths listed in `/etc/ramlog/ramlog.conf` to `/var/log/ramlog-archive` and writes a SHA-256 manifest. Historical files under `/var/log` are not deleted or truncated. Unexpected power loss or kernel panic can lose logs still resident in RAM.

The installer preserves an existing `/etc/ramlog/ramlog.conf`.

## Network security

The web server binds to `0.0.0.0:7780` and currently has no authentication or TLS. Restrict TCP 7780 to a trusted management network using the host firewall. Never expose it to the Internet.
