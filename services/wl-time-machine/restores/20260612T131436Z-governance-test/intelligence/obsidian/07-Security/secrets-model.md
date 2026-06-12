---
title: Secrets Model
type: security
status: canonical
version: 1.0.0
parent: "[[security-standard]]"
tags:
  - security
  - secrets
---

# Secrets Model

> [!abstract]
> Defines how Wonderland-v4 treats secrets and sensitive configuration.

## Secret Definition

A secret is any value that grants access, decrypts protected data, authenticates a system, or authorizes privileged action.

## Secret Examples

- Passwords
- API keys
- Tokens
- Private keys
- Recovery keys
- Database credentials
- Signing keys

## Prohibited Locations

Secrets shall not be stored in:

- Plaintext Markdown
- ADRs
- Git history
- Public logs
- Unencrypted backups
- Container images

## Secret References

Documentation may reference secret names, paths, or retrieval procedures.

Documentation must not expose secret values.

## Registry Requirement

Secret dependencies shall be recorded in [[secrets]] without exposing values.

## Recovery Requirement

Secrets must have a documented recovery or rotation procedure.

## Rotation

Secret rotation should document:

- Scope
- Affected services
- Verification procedure
- Rollback or reissue procedure

## Architect Constraint

> [!danger]
> Architect must not be the only holder or source of any secret.
