# Recovery Policy
<!-- id: recovery-policy-v4 -->

## Rule

Wonderland must be recoverable without AI assistance.

## Recovery Priority

1. Core Vault
2. Git Repository
3. Backups
4. Infrastructure
5. Automation
6. Services
7. Runtime State

## Minimum Recovery Requirements

A valid recovery path must include:

- Source location
- Restore command
- Verification command
- Rollback command
- Failure handling

## Backup Rule

Any system promoted into Wonderland core must define:

- What must be backed up
- Where backups are stored
- How backups are verified
- How backups are restored

## Status

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
