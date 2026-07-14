# Platform 0.3 Phase 6 — Architecture Certification Gate

## Purpose

The Architecture Certification Gate makes repository architecture enforceable.

A certification candidate must satisfy:

- zero architecture failures
- zero architecture warnings
- repository score of 100

## Commands

```bash
wl architecture gate
wl architecture-gate
Policy

The gate performs no migration.

It only prevents certification from proceeding when the repository model has drift or unclassified structure.
