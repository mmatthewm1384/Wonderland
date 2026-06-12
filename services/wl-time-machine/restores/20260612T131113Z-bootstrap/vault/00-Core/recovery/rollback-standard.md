# Rollback Standard
<!-- id: rollback-standard-v4 -->

## Rule

Any promoted change must be reversible or explicitly marked irreversible.

## Rollback Requirements

A rollback procedure must define:

- Previous known-good state
- Files changed
- Commands changed
- Services affected
- Restore command
- Verification command

## Failure Rule

If rollback fails, recovery policy takes priority.

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
