# Platform 0.4 Phase 3 — Registry Consumer Adapter

## Purpose

The Registry Consumer Adapter provides a stable import interface for engineering subsystems.

Architecture, builder, doctor, certification, and release code can consume registries through this adapter instead of loading JSON files directly.

## Files

```text
01-Platform/registry/service.py
01-Platform/registry/consumer.py
01-Platform/registry/consumer-smoke-test.py
Commands
bin/wl-registry-consumer
python3 01-Platform/registry/consumer-smoke-test.py
bin/wl-engineering-gate
Policy

This phase does not rewrite existing consumers yet.

It creates the compatibility layer required before deeper integration.
