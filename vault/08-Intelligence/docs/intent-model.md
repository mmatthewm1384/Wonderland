# Intent Model
<!-- id: intent-model-v4 -->

Purpose:
Defines proposed work before execution.

An intent captures:

- Desired outcome
- Operator
- Status
- Created timestamp
- Rollback statement

Valid states:

- draft
- approved
- rejected
- executed
- archived

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
