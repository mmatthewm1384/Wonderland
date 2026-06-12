---
title: Repository Strategy
type: platform
status: draft
version: 1.0.0
parent: "[[platform-foundation]]"
tags:
  - platform
  - git
  - repositories
---

# Repository Strategy

> [!abstract]
> Defines the initial repository model for Wonderland-v4.

## Repository Principles

Repositories shall be:

- Versioned
- Auditable
- Recoverable
- Purpose-specific
- Documented

## Initial Repository Set

```text
wonderland-docs
wonderland-platform
wonderland-automation
wonderland-services
wonderland-ops
```

## Repository Purposes

### `wonderland-docs`

Canonical documentation, governance, standards, ADRs, registries, and Obsidian vault content.

### `wonderland-platform`

Infrastructure definitions, platform configuration, networking, storage, and runtime definitions.

### `wonderland-automation`

Automation scripts, workflows, scheduled jobs, and provisioning logic.

### `wonderland-services`

Service definitions, compose files, manifests, and service-specific deployment assets.

### `wonderland-ops`

Operational procedures, maintenance scripts, recovery tooling, and audit utilities.

## Repository Registry

All repositories must be recorded in [[repositories]].

## Verification

Each repository should include:

- `README.md`
- `LICENSE` or explicit license decision
- `.gitignore`
- documented ownership
- recovery instructions

## Recovery

Repositories must be recoverable from remote Git plus documented local bootstrap procedures.

## Rollback

Repository changes shall be reverted through Git.
