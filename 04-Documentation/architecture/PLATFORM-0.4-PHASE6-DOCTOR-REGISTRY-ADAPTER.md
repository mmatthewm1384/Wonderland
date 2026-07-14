# Platform 0.4 Phase 6 — Doctor Registry Adapter

## Purpose

The engineering doctor now consumes the registry-backed engineering validation stack.

This creates a doctor-facing adapter without replacing the existing `wl doctor` framework yet.

## Command

```bash
bin/wl-doctor-engineering
Checks
Registry Service
Architecture Gate
Builder Ownership
Unified Engineering Gate
Policy

This phase does not replace existing doctor modules.

It introduces a stable engineering doctor entrypoint that future wl doctor orchestration can call.
