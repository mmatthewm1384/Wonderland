# Service Promotion Standard
<!-- id: service-promotion-v4 -->

Purpose:
Defines the path from blueprint to managed Wonderland service.

Stages:

1. Draft
2. Review
3. Verification
4. Promotion
5. Runtime
6. Registry

Requirements:

- Service definition
- Runtime definition
- Recovery procedure
- Verification procedure
- Registry entry
- Rollback path

Promotion rule:
Promotion must fail if verification, recovery, or registry evidence is missing.

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
