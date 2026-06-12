# Drift Standard
<!-- id: drift-standard-v4 -->

Purpose:
Defines how Wonderland detects configuration drift.

Drift sources:

- Vault files
- Service definitions
- Runtime inventory
- Registry state
- Git status

Rule:
Drift should be reported before promotion or recovery.

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
