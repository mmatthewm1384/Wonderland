# Backup Runbook
<!-- id: backup-runbook-v4 -->

## Objective

Perform a Wonderland backup.

## Procedure

1. Verify state
2. Snapshot repository
3. Snapshot vault
4. Snapshot runtime data
5. Verify backup

## Verification

```zsh
wl verify
Status

state: active
version: 4
