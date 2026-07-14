# Platform 0.4 Phase 2 — Registry-Backed Engineering Gate

## Purpose

The Unified Engineering Gate now validates the registry service before running architecture and builder checks.

This establishes the registry service as the first dependency in the engineering validation chain.

## Gate Order

```text
Registry Service
  ↓
Architecture Gate
  ↓
Builder Ownership
Command
bin/wl-engineering-gate
Policy

No files are moved.

This phase only changes gate orchestration.
