---
title: Documentation Standard
type: standard
status: canonical
version: 1.0.0
parent: "[[governance-framework]]"
tags:
  - governance
  - standard
  - documentation
---

# Documentation Standard

> [!abstract]
> Documentation is infrastructure.

## Purpose

Documentation preserves operational knowledge and enables Wonderland to be operated, recovered, and extended without relying on Architect.

## Canonical Rule

> [!important]
> A capability is not operational until its documentation exists.

## Required Service Documentation

Every service shall include:

- `service-overview.md`
- `installation.md`
- `configuration.md`
- `operations.md`
- `backup.md`
- `recovery.md`
- `decommission.md`

## Required Sections

Operational documents should include:

- Purpose
- Dependencies
- Configuration
- Installation
- Verification
- Recovery
- Rollback

## Source of Truth

The authoritative knowledge repository is [[obsidian-knowledge-core|Obsidian]].

## Compliance

A service without sufficient documentation is incomplete.
