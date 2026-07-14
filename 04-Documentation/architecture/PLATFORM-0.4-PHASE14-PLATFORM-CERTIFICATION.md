# Platform 0.4 Phase 14 — Platform Certification Command

## Purpose

The Platform Certification Command runs the registry-backed engineering platform checks as one auditable certification workflow.

## Commands

```bash
bin/wl-platform-certify
bin/wl-platform certify
wl platform certify
Checks
Registry Service
Architecture Gate
Builder Ownership
Engineering Gate
Release Preflight
Certification Preflight
Manifest Index
Platform Status
Output
05-Vault/generated/platform-certifications/<certification-id>/platform-certification-manifest.json
vault/08-Operations/certifications/<certification-id>.md
Policy

This phase performs no destructive changes.

It produces an auditable certification manifest and summary.
