# Platform 0.3 Phase 4 — Architecture Normalization

## Purpose

Architecture normalization converts raw top-level directory warnings into lifecycle-aware repository classifications.

The architecture engine now distinguishes:

- native constitutional directories
- compatibility aliases
- managed operational or generated paths
- retained historic directories
- truly unclassified paths

## Registry

```text
01-Platform/registry/repository-classification.json
States
State	Meaning
native	Canonical constitutional directory
compatibility	Legacy path intentionally retained during migration
managed	Operational, runtime, or generated path intentionally managed
retained	Historic or reference material intentionally retained
unclassified	No architecture registry entry
Commands
wl architecture status
wl architecture verify
wl architecture report
wl architecture explain <path>

wl repository status
wl repository verify
wl repository report
wl repository explain <path>
Policy

Normalization does not move files.

It improves architectural signal quality before migration.
