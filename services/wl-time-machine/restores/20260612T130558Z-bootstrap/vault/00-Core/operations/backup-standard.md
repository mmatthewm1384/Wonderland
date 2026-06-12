
Backup Standard
<!-- id: backup-standard-v4 -->
Rule

Promoted systems must define backup and restore behavior.

Backup Requirements

Each backup procedure must define:

Source path
Destination path
Frequency
Verification command
Restore command
Retention policy
Recovery Requirement

A backup is not valid until it has a documented restore path.

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
