---
title: Networking Model
type: platform
status: draft
version: 1.0.0
parent: "[[platform-foundation]]"
tags:
  - platform
  - networking
---

# Networking Model

> [!abstract]
> Defines the initial logical networking model for Wonderland-v4.

## Network Naming

Networks shall follow:

```text
wonderland-<scope>
```

## Initial Network Scopes

```text
wonderland-core
wonderland-services
wonderland-edge
wonderland-data
wonderland-admin
```

## Network Purposes

### `wonderland-core`

Core platform services.

### `wonderland-services`

General internal services.

### `wonderland-edge`

Ingress, reverse proxy, and public-facing boundaries.

### `wonderland-data`

Databases, storage services, and persistence systems.

### `wonderland-admin`

Administrative interfaces and operator-only tooling.

## Boundary Rule

> [!important]
> Services should only attach to networks they require.

## Registry Requirement

All networks shall be recorded in [[networks]].

## Verification

```shell
docker network ls
nerdctl network ls
```

## Recovery

Recreate networks from documented names and manifests.

## Rollback

Remove unused networks only after confirming no attached workloads.
