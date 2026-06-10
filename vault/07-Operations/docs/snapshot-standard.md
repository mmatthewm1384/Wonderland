# Snapshot Standard
<!-- id: snapshot-standard-v4 -->

Purpose:
Defines vault snapshot behavior.

Snapshot command:
    wl snapshot

Requirements:

- Verification before snapshot
- SHA-256 checksum
- Restore command
- Retention policy

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
