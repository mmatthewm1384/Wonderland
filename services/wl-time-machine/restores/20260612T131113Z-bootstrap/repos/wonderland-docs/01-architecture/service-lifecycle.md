---
title: Service Lifecycle
type: architecture
status: canonical
version: 1.0.0
parent: "[[wonderland-reference-architecture]]"
tags:
  - architecture
  - services
  - lifecycle
---

# Service Lifecycle

> [!abstract]
> Every Wonderland service exists within an identifiable lifecycle state.

## Lifecycle States

```text
Design
  ↓
Build
  ↓
Review
  ↓
Deploy
  ↓
Operate
  ↓
Recover
  ↓
Retire
```

## Design

The service purpose, boundaries, dependencies, and recovery model are defined.

## Build

The service is implemented but not yet approved for operation.

## Review

The service is evaluated against governance, security, documentation, and recovery standards.

## Deploy

The service is introduced into an operational environment.

## Operate

The service is maintained as an active capability.

## Recover

The service is restored after failure or rebuilt from documented procedures.

## Retire

The service is removed, archived, or replaced.

## Registry Requirement

Every service in [[services]] must have a lifecycle state.
