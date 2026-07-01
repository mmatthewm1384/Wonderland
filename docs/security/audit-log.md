# Wonderland Audit Log

## Overview

Wonderland Audit Log v1 is a local-first append-only JSONL event log for platform security, recovery, verification, and operational events.

## Files

```text
bin/wl-audit
vault/security/audit-policy.json
logs/security/audit.jsonl
docs/security/audit-log.md
Commands
wl audit log mirror.certified --status pass --message "Mirror certification passed"
wl audit tail
wl audit verify
wl audit report
Event Status Values
pass
fail
warn
info
Design Decisions
JSONL is used for append-only operational simplicity.
The log is local-first and does not require a network service.
The policy file defines required fields and allowed statuses.
Verification validates JSON syntax, required fields, and status values.
Recovery

If dispatcher wiring breaks, restore the latest backup:

cp builder/backups/wl-before-audit-dispatch-* bin/wl
chmod +x bin/wl

