---
title: Service Recovery Template
type: recovery
status: template
version: 1.0.0
parent: "[[recovery-standard]]"
tags:
  - recovery
  - template
  - services
---

# Service Recovery Template

## Service

`wl-<service>`

## Failure Scenario

Describe the failure condition.

## Impact

Describe affected users, data, services, or dependencies.

## Preconditions

Required access, tools, backups, and host state.

## Recovery Procedure

1. Stop affected service.
2. Preserve current state if safe.
3. Restore configuration.
4. Restore data.
5. Restart service.
6. Verify service.

## Verification

Document exact verification commands.

## Rollback

Document how to return to the pre-recovery state.

## Escalation

Document when Operator intervention is required.

## Notes

Record lessons learned after recovery.
