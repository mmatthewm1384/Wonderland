---
title: ADR-0003 Recoverability Over Convenience
type: adr
status: accepted
tags:
  - adr
  - recovery
---

# ADR-0003 Recoverability Over Convenience

## Status

Accepted

## Context

Wonderland is intended to be durable, persistent, and operationally recoverable.

## Decision

Recoverability takes precedence over convenience when design tradeoffs conflict.

## Consequences

Fast but fragile solutions should be rejected.

Recovery plans, backups, verification, and rollback procedures are required for critical systems.

## Alternatives Considered

Prioritize speed and convenience by default.

## References

- [[recovery-standard]]
- [[wonderland-constitution]]
