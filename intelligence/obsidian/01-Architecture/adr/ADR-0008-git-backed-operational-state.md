---
title: ADR-0008 Git-Backed Operational State
type: adr
status: accepted
tags:
  - adr
  - git
  - recovery
---

# ADR-0008 Git-Backed Operational State

## Status

Accepted

## Context

Wonderland needs auditable, recoverable operational configuration.

## Decision

Governance, documentation, automation, and configuration should be Git-backed wherever practical.

## Consequences

Operational state becomes reviewable and recoverable.

Secrets and mutable runtime data remain outside Git unless encrypted and explicitly approved.

## Alternatives Considered

Local-only unmanaged files.

## References

- [[git-strategy]]
- [[repository-strategy]]
- [[security-standard]]
