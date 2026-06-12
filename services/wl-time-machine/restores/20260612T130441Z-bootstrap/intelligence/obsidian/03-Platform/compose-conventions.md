---
title: Compose Conventions
type: platform
status: canonical
version: 1.0.0
parent: "[[container-runtime-policy]]"
tags:
  - platform
  - containers
  - compose
---

# Compose Conventions

> [!abstract]
> Defines baseline conventions for Compose-compatible service manifests.

## Purpose

Compose files provide a portable local service definition pattern for Wonderland-v4.

## File Name

```text
compose.yaml
```

## Project Name

When supported, use:

```text
name: wl-<service>
```

## Container Names

```text
container_name: wl-<service>
```

## Network Names

```text
wonderland-<scope>
```

## Volume Names

```text
wl-<service>-data
```

## Environment Files

```text
.env
.env.example
```

`.env.example` may be committed.

`.env` must not be committed when it contains local or secret values.

## Health Checks

Services should define health checks where supported.

## Labels

Services may include labels for:

- Ownership
- Documentation link
- Backup scope
- Lifecycle state

## Verification

```shell
docker compose config
docker compose ps
```

or:

```shell
nerdctl compose config
nerdctl compose ps
```

## Recovery

Compose manifests must be sufficient to recreate service containers after host or runtime failure.
