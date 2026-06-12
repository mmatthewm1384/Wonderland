---
title: ADR-0006 Platform Foundation
type: adr
status: accepted
tags:
  - adr
  - platform
---

# ADR-0006 Platform Foundation

## Status

Accepted

## Context

Wonderland-v4 needs a platform foundation before implementation begins.

## Decision

Adopt the platform foundation documents covering workspace layout, repository strategy, Git strategy, command interface, and implementation registry.

## Consequences

Platform work now has a governed starting point.

Future infrastructure decisions must conform to this platform foundation or supersede it by ADR.

## Alternatives Considered

Begin implementation without a platform foundation.

## References

- [[platform-foundation]]
- [[workspace-layout]]
- [[repository-strategy]]
- [[wl-command-interface]]
