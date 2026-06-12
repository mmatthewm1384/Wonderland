---
title: Security Standard
type: standard
status: canonical
version: 1.0.0
parent: "[[governance-framework]]"
tags:
  - governance
  - standard
  - security
---

# Security Standard

> [!abstract]
> Security is a design property.

## Purpose

Security protects Wonderland systems, data, credentials, identity, operational continuity, and trust boundaries.

## Principles

### Least Privilege

Grant only the access required to perform the intended function.

### Explicit Trust

Trust relationships must be documented.

### Separation of Secrets

Secrets shall never be stored in:

- Documentation
- Repositories
- ADRs
- Plaintext configuration

### Auditability

Access changes should be traceable.

## Required Security Documentation

All services shall document:

- Identity source
- Authentication method
- Authorization model
- Secret dependencies
- Trust boundaries
- External exposure

## Architect Constraint

Security controls must remain understandable and maintainable without Architect.
