---
title: Dependency Policy
type: architecture
status: canonical
version: 1.0.0
parent: "[[wonderland-reference-architecture]]"
tags:
  - architecture
  - dependency
  - governance
---

# Dependency Policy

> [!abstract]
> Any Wonderland component must be replaceable or explicitly exempted by ADR.

## Canonical Rule

> [!important]
> Any component may be replaced.

## Prohibited Dependencies

Wonderland shall avoid:

- Undocumented dependencies
- Single-human dependencies
- Architect runtime dependencies
- Hidden operational logic
- Irreversible vendor lock-in

## Vendor Lock-In

Vendor lock-in requires an ADR.

The ADR must document:

- Reason
- Risk
- Replacement path
- Export path
- Recovery implications

## Architect Dependency

> [!danger]
> No runtime capability may depend on Architect.

Architect may design, document, review, and generate automation.

Architect may not be required to operate, recover, or maintain Wonderland.
