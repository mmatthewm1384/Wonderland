---
title: Service Definition Standard
type: standard
status: canonical
version: 1.0.0
parent: "[[documentation-standard]]"
tags:
  - services
  - standard
  - platform
---

# Service Definition Standard

> [!abstract]
> Defines the minimum structure required for a Wonderland-v4 service.

## Purpose

A service definition makes a service installable, verifiable, recoverable, and replaceable.

## Required Service Fields

Every service must define:

- Name
- Purpose
- Owner
- Lifecycle state
- Runtime
- Networks
- Volumes
- Secret dependencies
- Backup method
- Recovery method
- Verification method
- Decommission procedure

## Naming

Service names shall follow:

```text
wl-<service>
```

## Required Documentation

Every service should include:

```text
docs/service-overview.md
docs/installation.md
docs/configuration.md
docs/operations.md
docs/backup.md
docs/recovery.md
docs/decommission.md
```

## Required Runtime Assets

Each service should include:

```text
compose.yaml
.env.example
README.md
```

## Required Operational Scripts

Where practical:

```text
scripts/verify.sh
scripts/backup.sh
scripts/recover.sh
scripts/rollback.sh
```

## Acceptance Criteria

A service is not operational until it is:

- Documented
- Versioned
- Verified
- Recoverable
- Registered in [[services]]
- Linked to relevant ADRs
