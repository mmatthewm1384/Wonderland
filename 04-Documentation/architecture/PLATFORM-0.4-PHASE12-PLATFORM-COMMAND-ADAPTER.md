# Platform 0.4 Phase 12 — Platform Command Adapter

## Purpose

The Platform Command Adapter provides a stable direct entrypoint for Platform 0.4 workflows without depending on the root `wl` dispatcher.

## Command

```bash
bin/wl-platform
Subcommands
bin/wl-platform status
bin/wl-platform gate
bin/wl-platform registry verify
bin/wl-platform architecture report
bin/wl-platform builder
bin/wl-platform doctor
bin/wl-platform release
bin/wl-platform certification
bin/wl-platform manifests
Policy

No existing dispatcher is replaced.

This adapter is additive and compatibility-first.
