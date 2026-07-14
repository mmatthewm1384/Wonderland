# Platform 0.4 Phase 16 — Platform Snapshot Command

## Purpose

The Platform Snapshot Command creates a reproducible operational snapshot of the Platform 0.4 control plane.

## Commands

```bash
bin/wl-platform-snapshot
bin/wl-platform snapshot
wl platform snapshot
Output
05-Vault/generated/snapshots/<snapshot-id>/platform-snapshot.json
Snapshot Contents
critical registry files
registry service files
architecture engine
certification and release adapters
manifest index service
platform status
engineering gate result
manifest index result
Git branch
Git HEAD
Git status
Policy

This phase performs no destructive changes.

It creates an auditable snapshot manifest.
