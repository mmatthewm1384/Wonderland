---
title: ADR-0017 Shell-First Command Layer
type: adr
status: accepted
tags:
  - adr
  - shell
  - automation
---

# ADR-0017 Shell-First Command Layer

## Status

Accepted

## Context

Wonderland must run across macOS and Linux with minimal bootstrap dependencies.

## Decision

Use POSIX-compatible shell scripts as the first `wl-*` command implementation layer.

## Consequences

Commands remain portable and easy to audit.

Higher-level implementations may be added later by ADR.

## Alternatives Considered

Start with Python, Swift, or compiled binaries.

## References

- [[command-standard]]
- [[automation-foundation]]
