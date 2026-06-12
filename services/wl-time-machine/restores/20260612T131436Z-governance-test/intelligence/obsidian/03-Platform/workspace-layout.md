---
title: Workspace Layout
type: platform
status: draft
version: 1.0.0
parent: "[[platform-foundation]]"
tags:
  - platform
  - workspace
---

# Workspace Layout

> [!abstract]
> Defines the recommended local filesystem structure for Wonderland-v4.

## Recommended Root

```text
~/Wonderland/
```

## Directory Structure

```text
~/Wonderland/
├── vault/
├── repos/
├── data/
├── backups/
├── exports/
├── logs/
├── secrets/
├── tmp/
└── tools/
```

## Directory Purposes

### `vault/`

Obsidian knowledge core.

### `repos/`

Git repositories.

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
test -d ~/Wonderland
test -d ~/Wonderland/vault
test -d ~/Wonderland/repos
```

## Recovery

Restore this layout from documentation and backups.

## Rollback

Remove newly created directories only after confirming no data loss.
