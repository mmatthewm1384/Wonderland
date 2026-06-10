---
title: ADR-0007 wl As Primary Command Interface
type: adr
status: accepted
tags:
  - adr
  - wl
  - automation
---

# ADR-0007 wl As Primary Command Interface

## Status

Accepted

## Context

Wonderland requires a consistent Operator-facing command interface.

## Decision

Adopt `wl-*` commands as the canonical command interface pattern.

## Consequences

Automation becomes discoverable and consistent.

Commands must be documented, scriptable, auditable, and recoverable.

## Alternatives Considered

Ad-hoc scripts without a command convention.

## References

- [[wl-command-interface]]
- [[naming-standard]]
