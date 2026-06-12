---
title: Runtime Verification
type: operations
status: draft
version: 1.0.0
parent: "[[container-runtime-policy]]"
tags:
  - operations
  - verification
  - runtime
---

# Runtime Verification

> [!abstract]
> Defines baseline runtime verification checks for Wonderland-v4.

## Purpose

Runtime verification confirms that container runtime, networks, volumes, and service manifests are operational.

## Host Checks

```shell
uname -a
whoami
pwd
```

## Runtime Checks

Docker:

```shell
docker version
docker ps
docker network ls
docker volume ls
```

nerdctl:

```shell
nerdctl version
nerdctl ps
nerdctl network ls
nerdctl volume ls
```

## Service Checks

Each service must define a service-specific verification command.

Examples:

```shell
docker compose ps
docker compose logs --tail=50
curl -fsS http://localhost:<port>/health
```

## Failure Handling

Verification failure must produce:

- Failed check
- Expected state
- Observed state
- Recommended recovery document
