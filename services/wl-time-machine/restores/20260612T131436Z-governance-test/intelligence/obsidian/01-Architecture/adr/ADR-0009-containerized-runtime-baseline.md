---
title: ADR-0009 Containerized Runtime Baseline
type: adr
status: accepted
tags:
  - adr
  - containers
  - runtime
---

# ADR-0009 Containerized Runtime Baseline

## Status

Accepted

## Context

Wonderland-v4 requires portable runtime patterns for services.

## Decision

Adopt a containerized runtime baseline compatible with Docker and nerdctl/containerd workflows.

## Consequences

Services should be described using portable manifests and documented runtime procedures.

Runtime-specific choices require documentation and may require ADRs.

## Alternatives Considered

Host-native installation as the default service model.

## References

- [[container-runtime-policy]]
- [[runtime-verification]]
