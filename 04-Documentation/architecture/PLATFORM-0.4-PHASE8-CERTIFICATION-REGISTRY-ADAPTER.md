# Platform 0.4 Phase 8 — Certification Registry Adapter

## Purpose

Certification preflight now consumes the registry-backed engineering and release validation stack.

This creates a certification-facing adapter before replacing existing certification workflows.

## Command

```bash
bin/wl-certification-preflight
Checks
Registry Service
Architecture Gate
Builder Ownership
Unified Engineering Gate
Release Preflight
Output
05-Vault/generated/certifications/<certification-id>/certification-manifest.json
Policy

This phase performs no destructive changes.

It emits an auditable certification manifest.
