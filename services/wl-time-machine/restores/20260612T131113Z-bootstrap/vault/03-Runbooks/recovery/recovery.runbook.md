# Recovery Runbook
<!-- id: recovery-runbook-v4 -->

## Objective

Restore Wonderland after disruption.

## Procedure

1. Assess failure
2. Restore backups
3. Verify vault
4. Restore infrastructure
5. Restore services
6. Validate operation

## Verification

```zsh
wl verify
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
