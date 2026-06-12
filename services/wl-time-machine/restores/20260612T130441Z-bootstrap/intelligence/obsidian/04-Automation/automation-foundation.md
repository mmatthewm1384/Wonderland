---
title: Automation Foundation
type: automation
status: draft
version: 1.0.0
parent: "[[wl-command-interface]]"
tags:
  - automation
  - wl
  - foundation
---

# Automation Foundation

> [!abstract]
> Defines the initial automation foundation for Wonderland-v4.

## Purpose

The automation foundation establishes a durable, auditable, and recoverable command layer for Wonderland operations.

## Canonical Interface

Wonderland automation uses the `wl-*` command pattern.

## Initial Commands

- `wl-init`
- `wl-status`
- `wl-verify`
- `wl-backup`
- `wl-recover`
- `wl-export`

## Design Rules

Commands must be:

- Human-readable
- Shell-compatible
- Version-controlled
- Documented
- Safe by default
- Operable without Architect

## Runtime Constraint

> [!danger]
> Architect may generate automation.
>
> Wonderland must not depend upon Architect to run automation.
