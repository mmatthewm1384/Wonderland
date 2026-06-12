---
title: Workspace Layout
type: platform
status: canonical
version: 1.1.0
parent: "[[platform-foundation]]"
tags:
  - platform
  - workspace
---

# Workspace Layout

> [!abstract]
> Defines the canonical local filesystem structure for Wonderland-v4.

## Recommended Root

```text
~/Wonderland/
```

## Canonical Directory Structure

```text
~/Wonderland/
├── repos/
│   ├── wonderland-docs/
│   ├── wonderland-platform/
│   ├── wonderland-automation/
│   ├── wonderland-services/
│   └── wonderland-ops/
├── data/
├── backups/
├── exports/
├── logs/
├── secrets/
├── tmp/
└── tools/
```

## Canonical Knowledge Core

```text
~/Wonderland/repos/wonderland-docs
```

This directory is both:

- Git repository
- Obsidian vault

> [!important]
> There is no separate canonical `~/Wonderland/vault`.

## Directory Purposes

### `repos/wonderland-docs/`

Obsidian knowledge core and canonical documentation repository.

### `repos/`

All Wonderland Git repositories.

### `data/`

Local service data, datasets, and non-secret runtime state.

### `backups/`

Backup artifacts and recovery checkpoints.

### `exports/`

Generated exports, handoff bundles, and portable snapshots.

### `logs/`

Operational logs and command output.

### `secrets/`

Local secret references and encrypted secret material only.

> [!danger]
> Plaintext secrets must not be committed.

### `tmp/`

Disposable working files.

### `tools/`

Local tools, scripts, and helper binaries.

## Verification

```shell
test -d ~/Wonderland/repos/wonderland-docs
test -d ~/Wonderland/repos
test -d ~/Wonderland/tools
```

## Recovery

Restore `~/Wonderland/repos/wonderland-docs` from Git or verified backup.

## Rollback

Move incorrect installs aside before restoring:

```shell
mv ~/Wonderland/repos/wonderland-docs ~/Wonderland/repos/wonderland-docs.rollback.$(date +%Y%m%d-%H%M%S)
```
