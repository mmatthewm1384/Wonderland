# Platform 0.4 Phase 7 — Release Registry Adapter

## Purpose

Release preflight now consumes the registry-backed engineering validation stack.

This creates a release-facing adapter before replacing any existing release system.

## Command

```bash
bin/wl-release-preflight
Checks
Registry Service
Architecture Gate
Builder Ownership
Unified Engineering Gate
Output
05-Vault/generated/releases/<release-id>/release-manifest.json
Policy

This phase performs no release promotion and no destructive changes.

It creates an auditable preflight manifest.
