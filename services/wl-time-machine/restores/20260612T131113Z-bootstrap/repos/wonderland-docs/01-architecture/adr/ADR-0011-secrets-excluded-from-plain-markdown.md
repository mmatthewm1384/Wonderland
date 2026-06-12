---
title: ADR-0011 Secrets Excluded From Plain Markdown
type: adr
status: accepted
tags:
  - adr
  - security
  - secrets
---

# ADR-0011 Secrets Excluded From Plain Markdown

## Status

Accepted

## Context

Wonderland uses Markdown and Obsidian as its knowledge core, but plaintext documentation is not an appropriate storage location for secrets.

## Decision

Secrets shall not be stored in plaintext Markdown, ADRs, repositories, public logs, unencrypted backups, or container images.

## Consequences

Documentation may reference secret names and recovery procedures but not secret values.

Secret storage and recovery require dedicated procedures.

## Alternatives Considered

Store low-risk secrets directly in documentation.

## References

- [[secrets-model]]
- [[security-standard]]
