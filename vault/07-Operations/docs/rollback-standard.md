# Rollback Standard
<!-- id: operations-rollback-standard-v4 -->

Purpose:
Defines how Wonderland rolls back operational changes.

Rollback sources:

- Git history
- Vault snapshots
- Pre-restore backups
- Archived files
- Registry records

Requirements:

- Identify changed files
- Identify previous known-good state
- Restore or revert
- Verify
- Record evidence

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
