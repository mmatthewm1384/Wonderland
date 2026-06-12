# Continuity Plan
<!-- id: continuity-plan-v4 -->

## Purpose

Define how Wonderland continues after major disruption.

## Scenarios

### Workstation Failure

Restore from repository and backups on a new machine.

### External Drive Failure

Restore from backup copy or archive.

### Repository Corruption

Restore from remote or last verified backup.

### Service Failure

Restart service, inspect logs, verify dependencies, recover from documented state.

### AI Unavailable

Use vault documents, scripts, manifests, and runbooks.

## Rule

Wonderland must remain understandable and recoverable without external AI memory.

## Status

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
