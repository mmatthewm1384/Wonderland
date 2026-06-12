---
title: Container Runtime Policy
type: platform
status: canonical
version: 1.0.0
parent: "[[platform-foundation]]"
tags:
  - platform
  - containers
  - runtime
---

# Container Runtime Policy

> [!abstract]
> Defines the baseline policy for container runtime use in Wonderland-v4.

## Purpose

Wonderland services should be portable across compatible container runtimes.

## Supported Runtime Pattern

Wonderland may use:

- Docker
- nerdctl
- containerd-compatible workflows

## Runtime Constraint

> [!important]
> Service definitions should avoid unnecessary runtime-specific lock-in.

Runtime-specific behavior requires documentation and, when significant, an ADR.

## Container Naming

Containers shall follow:

```text
wl-<service>
```

## Service Naming

Services shall follow:

```text
wl-<service>
```

## Required Service Assets

Each containerized service should include:

- Compose or runtime manifest
- Environment template
- Volume declaration
- Network declaration
- Backup notes
- Recovery notes
- Verification command

## Verification

```shell
docker ps
nerdctl ps
```

Use the runtime applicable to the host.

## Recovery

Container workloads must be recoverable from:

1. Versioned manifests
2. Documented configuration
3. Restored volumes or backups
4. Registry images or rebuild process

## Rollback

Rollback is performed by reverting manifests, restoring previous image versions, and restoring prior volume state where required.
