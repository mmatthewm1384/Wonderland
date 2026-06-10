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

## Governance Principle

This component may be destroyed and rebuilt without loss of authority.

Authority resides in:

- documented intent
- service definitions
- recovery procedures
- version-controlled governance records

Runtime state is disposable.
Authority is not.
