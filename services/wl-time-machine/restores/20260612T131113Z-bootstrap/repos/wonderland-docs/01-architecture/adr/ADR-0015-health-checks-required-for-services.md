---
title: ADR-0015 Health Checks Required For Services
type: adr
status: accepted
tags:
  - adr
  - health
  - services
---

# ADR-0015 Health Checks Required For Services

## Status

Accepted

## Context

Services need repeatable verification procedures to support operation, monitoring, and recovery.

## Decision

Every operational service must document a health check or verification command.

## Consequences

Service status becomes testable.

Recovery procedures can depend on explicit verification steps.

## Alternatives Considered

Rely on manual inspection only.

## References

- [[health-check-standard]]
- [[runtime-verification]]
