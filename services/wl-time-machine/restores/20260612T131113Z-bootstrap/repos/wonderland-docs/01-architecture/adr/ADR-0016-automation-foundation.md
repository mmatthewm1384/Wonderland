---
title: ADR-0016 Automation Foundation
type: adr
status: accepted
tags:
  - adr
  - automation
  - wl
---

# ADR-0016 Automation Foundation

## Status

Accepted

## Context

Wonderland requires repeatable operations while preserving manual recoverability.

## Decision

Adopt the automation foundation and initial `wl-*` command scaffold.

## Consequences

Common operations become scriptable and auditable.

Manual procedures remain required for recovery independence.

## Alternatives Considered

Delay automation until after services are deployed.

## References

- [[automation-foundation]]
- [[command-standard]]
- [[wl-command-interface]]
