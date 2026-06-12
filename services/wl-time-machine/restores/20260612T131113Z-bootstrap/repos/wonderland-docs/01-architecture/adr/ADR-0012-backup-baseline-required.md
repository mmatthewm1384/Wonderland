---
title: ADR-0012 Backup Baseline Required
type: adr
status: accepted
tags:
  - adr
  - backup
  - recovery
---

# ADR-0012 Backup Baseline Required

## Status

Accepted

## Context

Wonderland requires recoverable state before production services are trusted.

## Decision

Adopt the Backup Baseline as the minimum backup model for Wonderland-v4.

## Consequences

Critical services must define backup, restore, and verification procedures.

Backups without verification are not considered complete.

## Alternatives Considered

Delay backup design until after service deployment.

## References

- [[backup-baseline]]
- [[recovery-standard]]
