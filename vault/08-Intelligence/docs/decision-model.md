# Decision Model
<!-- id: decision-model-v4 -->

Purpose:
Defines how Wonderland records decisions.

A decision should capture:

- Context
- Options considered
- Chosen path
- Reason
- Consequences
- Rollback or revisit condition

Rule:
Major architectural changes require decision records.

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
