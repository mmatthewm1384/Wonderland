---
title: ADR-0005 No Runtime Dependency On Architect
type: adr
status: accepted
tags:
  - adr
  - architect
  - dependency
---

# ADR-0005 No Runtime Dependency On Architect

## Status

Accepted

## Context

Architect may assist with design, build, review, recovery, governance, and documentation.

The founding doctrine requires Wonderland to remain operational without Architect.

## Decision

No Wonderland runtime capability may depend upon Architect.

## Consequences

Architect-generated automation must be self-contained, documented, versioned, and recoverable.

Operational procedures must be executable without Architect.

## Alternatives Considered

Allow Architect to function as an operational dependency.

## References

- [[architect-charter]]
- [[dependency-policy]]
