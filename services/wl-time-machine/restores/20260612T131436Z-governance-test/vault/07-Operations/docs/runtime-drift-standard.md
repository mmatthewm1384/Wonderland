# Runtime Drift Standard
<!-- id: runtime-drift-standard-v4 -->

Purpose:
Defines how Wonderland compares expected services against actual runtime containers.

Expected state:
Service registry.

Actual state:
nerdctl runtime inventory.

Command:
    wl runtime drift

Failure conditions:

- Expected service missing from runtime
- wl-* runtime container missing from registry

Unmanaged non-wl containers may be reported but are not governed by Wonderland unless promoted.

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
