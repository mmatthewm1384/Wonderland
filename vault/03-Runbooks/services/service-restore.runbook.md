# Service Restore Runbook
<!-- id: service-restore-runbook-v4 -->

## Objective

Restore a Wonderland service.

## Procedure

1. Stop service
2. Restore configuration
3. Restore data
4. Start service
5. Verify service

## Verification

```zsh
wl status
Status

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
