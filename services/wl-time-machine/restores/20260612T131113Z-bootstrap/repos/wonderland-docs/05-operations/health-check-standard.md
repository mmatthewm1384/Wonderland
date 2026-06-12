---
title: Health Check Standard
type: operations
status: canonical
version: 1.0.0
parent: "[[service-definition-standard]]"
tags:
  - operations
  - health
  - services
---

# Health Check Standard

> [!abstract]
> Defines baseline health check expectations for Wonderland-v4 services.

## Purpose

Health checks provide a repeatable way to determine whether a service is functioning.

## Required Health Signals

A service should define at least one of:

- Process check
- Container status check
- HTTP health endpoint
- TCP connectivity check
- Log-based readiness indicator
- Application-specific verification command

## Health Check Properties

A health check should be:

- Scriptable
- Non-destructive
- Fast
- Documented
- Repeatable

## Verification Command

Every service should expose or document:

```shell
./scripts/verify.sh
```

## Failure Output

A failed health check should identify:

- Failed condition
- Expected state
- Observed state
- Next recovery document

## Recovery Link

Each service health check should reference its recovery document.
