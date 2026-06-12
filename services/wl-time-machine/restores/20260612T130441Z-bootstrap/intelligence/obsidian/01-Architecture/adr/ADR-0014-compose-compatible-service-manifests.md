---
title: ADR-0014 Compose-Compatible Service Manifests
type: adr
status: accepted
tags:
  - adr
  - compose
  - services
---

# ADR-0014 Compose-Compatible Service Manifests

## Status

Accepted

## Context

Wonderland needs a portable and understandable service definition format for containerized services.

## Decision

Use Compose-compatible manifests as the baseline service deployment format where practical.

## Consequences

Services can be operated with Docker Compose or nerdctl-compatible workflows.

Runtime-specific deviations require documentation.

## Alternatives Considered

Use only imperative shell scripts or host-native installation.

## References

- [[compose-conventions]]
- [[container-runtime-policy]]
