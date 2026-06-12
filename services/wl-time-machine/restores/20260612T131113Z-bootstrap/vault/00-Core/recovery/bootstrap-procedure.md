# Bootstrap Procedure
<!-- id: bootstrap-procedure-v4 -->

## Goal

Rebuild Wonderland from a clean machine.

## Required Inputs

- Core Vault
- Git Repository
- Backup Storage

## Sequence

Step 1

Restore repository.

Step 2

Verify core vault.

Step 3

Restore infrastructure.

Step 4

Restore automation.

Step 5

Restore services.

Step 6

Run verification.

Step 7

Promote operational state.

## Validation

The following must succeed:

- wl verify
- wl doctor
- wl status

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
