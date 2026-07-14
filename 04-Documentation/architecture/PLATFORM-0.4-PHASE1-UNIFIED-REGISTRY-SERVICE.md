# Platform 0.4 Phase 1 — Unified Registry Service

## Purpose

The Unified Registry Service centralizes registry loading, validation, inspection, and path explanation.

It is the compatibility-first service layer above the existing JSON registries.

## Registry Files

- `repository-layout.json`
- `repository-ownership.json`
- `repository-rules.json`
- `repository-aliases.json`
- `repository-classification.json`
- `builder-ownership.json`

## Commands

```bash
bin/wl-registry status
bin/wl-registry list
bin/wl-registry verify
bin/wl-registry show ownership
bin/wl-registry show classification classifications.bin
bin/wl-registry explain builder/python
Policy

This phase does not move or rewrite existing registry files.

It introduces a shared service so future architecture, builder, doctor, certification, and release workflows query registries through one interface.
