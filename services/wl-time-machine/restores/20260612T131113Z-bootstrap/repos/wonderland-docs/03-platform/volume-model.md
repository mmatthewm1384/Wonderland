---
title: Volume Model
type: platform
status: canonical
version: 1.0.0
parent: "[[platform-foundation]]"
tags:
  - platform
  - storage
  - volumes
---

# Volume Model

> [!abstract]
> Defines the persistent storage model for Wonderland-v4 services.

## Volume Naming

Volumes shall follow:

```text
wl-<service>-data
```

## Volume Classes

### Runtime Data

Mutable service state.

### Configuration Data

Service configuration that is not secret.

### Backup Data

Backup outputs and restore checkpoints.

### Export Data

Portable exports and migration artifacts.

## Persistence Rule

> [!important]
> Any data required after container recreation must live outside the container filesystem.

## Registry Requirement

All persistent volumes shall be recorded in [[volumes]].

## Backup Requirement

Each persistent volume must define:

- Backup method
- Restore method
- Verification method
- Retention expectation

## Verification

```shell
docker volume ls
nerdctl volume ls
```

## Recovery

Restore volumes from backup or regenerate from documented source state.

## Rollback

Rollback volume changes only with explicit backup or snapshot confirmation.
