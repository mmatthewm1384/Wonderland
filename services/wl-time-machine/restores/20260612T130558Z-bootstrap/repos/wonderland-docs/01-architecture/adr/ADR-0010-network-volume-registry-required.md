---
title: ADR-0010 Network And Volume Registry Required
type: adr
status: accepted
tags:
  - adr
  - registry
  - networking
  - volumes
---

# ADR-0010 Network And Volume Registry Required

## Status

Accepted

## Context

Untracked networks and volumes create recovery and audit risk.

## Decision

All persistent volumes and non-ephemeral networks must be recorded in the appropriate registry.

## Consequences

Service definitions must declare their network and volume dependencies.

Recovery procedures can reconstruct required runtime state.

## Alternatives Considered

Allow networks and volumes to exist without registry entries.

## References

- [[networking-model]]
- [[volume-model]]
- [[networks]]
- [[volumes]]
