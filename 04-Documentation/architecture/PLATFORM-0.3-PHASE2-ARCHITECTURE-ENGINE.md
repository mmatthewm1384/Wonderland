# Platform 0.3 Phase 2 — Architecture Engine

## Purpose

The Architecture Engine provides shared validation for Wonderland's constitutional repository model.

It consumes the repository registry instead of hardcoding architectural rules into unrelated commands.

## Commands

```bash
wl architecture status
wl architecture verify
wl architecture doctor
wl architecture report
wl architecture explain <path>
Validation Scope
Constitutional directories exist.
Registry files exist.
Registry files contain valid JSON.
Constitutional areas have owners.
Constitutional areas have purposes.
Compatibility aliases resolve to constitutional areas.
Unregistered top-level directories are reported as warnings.
Compatibility Policy

This phase performs no destructive moves.

Warnings identify migration candidates without failing verification.
