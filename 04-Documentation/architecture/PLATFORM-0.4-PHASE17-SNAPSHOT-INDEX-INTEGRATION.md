# Platform 0.4 Phase 17 — Snapshot Index Integration

## Purpose

Platform snapshots are now indexed by the Manifest Index Service.

## Indexed Sources

```text
05-Vault/generated/releases
05-Vault/generated/certifications
05-Vault/generated/platform-certifications
05-Vault/generated/snapshots
Commands
bin/wl-platform-snapshot
bin/wl-manifest-index
bin/wl-platform-status
Policy

This phase performs no destructive changes.

It only expands generated manifest discovery.
