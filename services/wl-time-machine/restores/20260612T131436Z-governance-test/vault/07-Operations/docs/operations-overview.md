# Operations Overview
<!-- id: operations-overview-v4 -->

Purpose:
Defines the operational control layer for Wonderland.

Domains:

- Audit
- Snapshot
- Restore
- Rollback
- Drift detection
- Promotion
- Lifecycle reporting
- State capture

Rule:
Operational procedures must be verifiable, repeatable, and recoverable.

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
