# Platform 0.4 Phase 5 — Builder Registry Adapter

## Purpose

Builder ownership verification now consumes builder registry data through the Registry Consumer Adapter.

This removes direct JSON ownership from the builder check and aligns builder validation with the unified registry service.

## Command

```bash
bin/wl-builder-ownership
Registry Source
01-Platform/registry/consumer.py
  -> 01-Platform/registry/service.py
  -> 01-Platform/registry/builder-ownership.json
Policy

No builder files are moved.

This phase changes registry access only.
