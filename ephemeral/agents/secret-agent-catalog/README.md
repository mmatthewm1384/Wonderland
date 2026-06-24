# Ephemeral Secret Agent Catalog — Wonderland Component

**Classification:** OPERATOR EYES ONLY  
**Integrated with:** Ephemeral Catalog Launcher, Custom Companions, FSEvent agents, generative visual effects  
**Date:** 2026-06-22

## Overview
This directory contains the production-ready implementation of the **Wonderland Ephemeral / Secret Agent Style Compendium** and its supporting CLI agent.

- `secret-agent-catalog.md` — The comprehensive, human-readable, categorized reference of every pattern that can be built in ephemeral or secret-agent style across visuals, automation, companions, state, macOS/Swift, security, and launchers.
- `secret_agent_catalog.py` — stdlib-only Python microservice companion (Catalog Agent). Queryable CLI for listing, searching, generating sample mission intents, and producing briefings. Fully ephemeral launchable (copy to /tmp, run, remove).
- `wl-secret-agent` — Bash shim implementing the exact `wl <service>` contract (`up`/`down`/`status`/`logs`/`doctor`/`repair`/`catalog`). Delegates heavy lifting to the Python agent. Provides Operator-uniform interface.

## Core Tenets Enforced
- **Recoverability > Convenience**: Every pattern defines explicit cleanup, TTL, and rollback. `wl ... repair` and graceful termination protocol are mandatory.
- **Auditability > Speed**: Minimal but sufficient aether logging, intent.json as mission orders, doctor/repair separation (read-only vs mutate).
- **Simplicity > Cleverness**: No over-obfuscation. stdlib Python only. Clear naming. No global packages. Intent-driven.

## Quick Start (Ephemeral Usage)
```bash
# From this directory or after symlinking wl-secret-agent into PATH
./wl-secret-agent catalog list-categories
./wl-secret-agent catalog list --category "Visual & Generative Effects" --verbose
./wl-secret-agent catalog search "slam OR chaos OR attention"
./wl-secret-agent catalog generate-intent infiltrator-atom --output /tmp/sample-intent.json
./wl-secret-agent catalog briefing --style secret-agent

# Full wl-style operations
./wl-secret-agent doctor
./wl-secret-agent repair
./wl-secret-agent up
```

## Integration Notes
- The Catalog Agent is itself an example of a **Custom Companion** (transient, stdlib, self-terminating).
- Extend the compendium by dropping updates to `~/Wonderland/vault/ephemeral-secret-agent-catalog.md` (authoritative) or via `wl secret-agent catalog repair --add`.
- All new visual effects, FSEvent agents, or automation should reference this compendium and declare their `ephemeral` / `secret` traits in their intent.json.
- The existing Ephemeral Catalog Launcher can be extended with `--style=secret-agent` filter using this agent as backend.

## File Manifest
- `secret-agent-catalog.md` (comprehensive list — source of truth for humans)
- `secret_agent_catalog.py` (machine-queryable agent + intent generator)
- `wl-secret-agent` (Operator CLI entrypoint)
- `README.md` (this file)

## Verification
Run:
```bash
./wl-secret-agent doctor
./wl-secret-agent catalog list | head -30
python3 -m py_compile secret_agent_catalog.py && echo "Python syntax OK"
```

## Recovery
```bash
./wl-secret-agent repair
# Or manual:
rm -rf /tmp/wonderland-mission-*
```

This component was implemented following the exact 8-part Wonderland engineering blueprint and is ready for Operator deployment or extension.

**Operator has final authority. AI advised and implemented; system runs independently.**
