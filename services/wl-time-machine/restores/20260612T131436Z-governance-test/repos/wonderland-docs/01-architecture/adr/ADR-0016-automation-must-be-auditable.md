---
title: ADR-0016 Automation Must Be Auditable
type: adr
status: accepted
tags:
  - adr
  - automation
  - audit
---

# ADR-0016 Automation Must Be Auditable

## Status

Accepted

## Context

Automation can obscure operational behavior if it is not documented and logged.

## Decision

Wonderland automation must be auditable, documented, and recoverable.

## Consequences

Automation must describe inputs, outputs, side effects, verification, and rollback.

## Alternatives Considered

Permit opaque scripts when they work.

## References

- [[automation-standard]]
- [[audit-logging-standard]]
