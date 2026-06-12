# Plan Model
<!-- id: plan-model-v4 -->

Purpose:
Defines the planned steps for an approved intent.

A plan captures:

- Intent reference
- Steps
- Status
- Rollback
- Created timestamp

Rule:
Plans must be approved before execution.

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
