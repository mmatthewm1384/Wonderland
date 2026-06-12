---
title: Implementation Registry
type: registry
status: active
version: 1.0.0
parent: "[[governance-framework]]"
tags:
  - registry
  - implementation
---

# Implementation Registry

> [!abstract]
> Tracks implementation state across Wonderland-v4.

## Purpose

The implementation registry records what exists, where it lives, and whether it is governed.

## Registry Fields

| Item | Domain | Status | Repository | Documentation | ADR | Recovery |
|---|---|---|---|---|---|---|

## Status Values

```text
proposed
designed
built
reviewed
operational
recoverable
retired
```

## Rules

Every implementation must link to:

- Documentation
- Owning repository
- Relevant ADR
- Recovery procedure

## Verification

Registry entries should be reviewed during platform audits.
