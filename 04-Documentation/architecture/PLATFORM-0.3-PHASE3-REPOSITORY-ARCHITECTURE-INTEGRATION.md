# Platform 0.3 Phase 3 — Repository Architecture Integration

## Purpose

Repository verification now delegates to the shared Architecture Engine.

This prevents duplicated validation logic between:

- `wl repository`
- `wl architecture`
- future `wl doctor`
- future `wl certify`
- future `wl builder`
- future `wl release`

## Commands

```bash
wl repository status
wl repository verify
wl repository doctor
wl repository report
wl repository explain <path>
These commands now consume the same architectural model as:

wl architecture status
wl architecture verify
wl architecture report
wl architecture explain <path>
Policy

No files are moved.

This phase only consolidates validation behavior.
