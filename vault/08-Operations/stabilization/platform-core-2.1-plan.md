# Wonderland Platform Core 2.1 Stabilization Plan

Goal: Refactor and stabilize Platform Core without adding new user-facing features.

## Scope

- Consolidate duplicated lifecycle logic.
- Keep `wl boot`, `wl verify`, `wl start`, `wl release`, and `wl checkpoint` passing.
- Preserve T7-detached behavior as WARN, not FAIL.
- Keep `bin/` commands thin.
- Move reusable implementation into `lib/core/`.
- Strengthen JSON, release, baseline, checkpoint, and runtime object validation.

## Non-goals

- No new apps.
- No new services.
- No visual/UI changes.
- No behavioral expansion of Wonderland capabilities.

## Required passing gates

```bash
wl boot
wl lint
wl test
wl verify
wl release status
wl checkpoint status
wl start
