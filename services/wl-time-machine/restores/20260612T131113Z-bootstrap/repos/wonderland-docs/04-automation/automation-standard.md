---
title: Automation Standard
type: standard
status: canonical
version: 1.0.0
parent: "[[governance-framework]]"
tags:
  - automation
  - standard
  - wl
---

# Automation Standard

> [!abstract]
> Defines how automation is designed, documented, verified, and recovered in Wonderland-v4.

## Purpose

Automation reduces repetitive work while preserving operator control, auditability, and recoverability.

## Canonical Rule

> [!important]
> Automation may assist operations.
>
> Automation must not obscure operations.

## Automation Requirements

Automation shall be:

- Documented
- Versioned
- Auditable
- Recoverable
- Safe by default
- Explicit about destructive actions
- Operable without Architect

## Required Sections

Each automation must document:

- Purpose
- Inputs
- Outputs
- Preconditions
- Side effects
- Verification
- Recovery
- Rollback

## Destructive Operations

Destructive operations require:

- Explicit command flag
- Operator-readable warning
- Documented rollback or recovery path

## Idempotency

Automation should be idempotent where practical.

If not idempotent, the limitation must be documented.

## Logging

Automation should write logs to:

```text
~/Wonderland/logs/
```

## Exit Codes

```text
0   success
1   general failure
2   invalid usage
3   missing dependency
4   verification failed
5   unsafe operation blocked
```
