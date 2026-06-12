---
title: wl Command Interface
type: automation
status: draft
version: 1.0.0
parent: "[[platform-foundation]]"
tags:
  - automation
  - cli
  - wl
---

# wl Command Interface

> [!abstract]
> Defines the canonical command interface for Wonderland-v4.

## Purpose

`wl` is the primary Operator-facing command interface for Wonderland.

## Naming Rule

Commands follow:

```text
wl-<action>
```

## Initial Command Categories

```text
wl-init
wl-status
wl-verify
wl-backup
wl-recover
wl-export
wl-registry
wl-service
wl-platform
```

## Command Requirements

Every command shall include:

- Purpose
- Usage
- Inputs
- Outputs
- Exit codes
- Verification behavior
- Recovery behavior

## Command Design

Commands must be:

- Scriptable
- Auditable
- Idempotent where practical
- Safe by default
- Documented
- Operable without Architect

## Exit Code Standard

```text
0   success
1   general failure
2   invalid usage
3   missing dependency
4   verification failed
5   unsafe operation blocked
```

## Verification

```shell
command -v wl-status
wl-status --help
```

## Recovery

Commands must not be the only recovery path.

Manual recovery procedures must also exist.

## Rollback

Command changes are rolled back through Git.
